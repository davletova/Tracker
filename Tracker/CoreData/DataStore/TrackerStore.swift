//
//  TrackerStore.swift
//  Tracker
//
//  Created by Алия Давлетова on 25.08.2023.
//

import Foundation
import CoreData
import UIKit

enum TrackerStoreError: Error {
    case decodingErrorInvalidId
    case decodingErrorInvalidName
    case decodingErrorInvalidCategory
    case decodingErrorInvalidCategoryName
    case decodingErrorInvalidEmojies
    case decodingErrorInvalidColorHex
    case categoryNotFound
    case generateURLError
    case getTrackerError
}

struct TrackerStoreUpdate {
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
    let updatedIndexes: IndexSet
}

final class TrackerStore: NSObject, TrackerStoreProtocol {
    private let context: NSManagedObjectContext
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "createDate", ascending: true)
        ]
        
        return NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: "category",
            cacheName: nil
        )
    }()
    
    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        try! self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) throws {
        self.context = context
        super.init()
        
        self.fetchedResultsController.delegate = self
        try fetchedResultsController.performFetch()
    }
    
    func getTrackers(by date: Date, withName name: String?) -> [TrackersByCategory] {
        let request = TrackerCoreData.fetchRequest()
        request.returnsObjectsAsFaults = false
        request.sortDescriptors = [NSSortDescriptor(key: "createDate", ascending: true)]
                
        let dayOfWeek = String(describing: date.dayNumberOfWeek())
        
        var requestPredicate = NSCompoundPredicate.init(type: .or, subpredicates: [
            NSCompoundPredicate.init(type: .and, subpredicates: [
                NSPredicate(format: "%K != nil", #keyPath(TrackerCoreData.schedule)),
                NSPredicate(format: "%K.\(dayOfWeek) = true", #keyPath(TrackerCoreData.schedule)),
            ]),
            NSPredicate(format: "%K == nil", #keyPath(TrackerCoreData.schedule))
        ])
        
        if let name = name, !name.isEmpty {
            requestPredicate = NSCompoundPredicate.init(type: .and, subpredicates: [
                requestPredicate,
                NSPredicate(format: "%K CONTAINS[cd] %@", #keyPath(TrackerCoreData.name), name)
            ])
        }
        
        request.predicate = requestPredicate
        
        guard let trackers = try? context.fetch(request) else {
            print("trackerStore: getTrackers request failed")
            return [TrackersByCategory]()
        }
        
        let trackersByCategoryDictionary = Dictionary(grouping: trackers) { (tracker) -> String in
            guard
                let category = tracker.category,
                let categoryName = tracker.pinned ? "Закреп" : category.name
            else {
                assertionFailure("failed to get category name of tarcker \(tracker.id)")
                return ""
            }
            
            return categoryName
        }
        
       return trackersByCategoryDictionary.map { (categoryName: String, trackersManaged: [TrackerCoreData]) in
            var trackers = [TrackerViewModel]()
            for trackerManaged in trackersManaged {
                guard let tracker = try? makeTracker(from: trackerManaged, date: date) else {
                    print("failed to make tracker from \(String(describing: trackerManaged.name))")
                    continue
                }
                trackers.append(tracker)
            }
            return TrackersByCategory(categoryName: categoryName, trackers: trackers)
       }.sorted { cat1, cat2 in
           if cat1.categoryName == "Закреп" {
               return true
           }
           
           if cat2.categoryName == "Закреп" {
               return false
           }
           
           return cat1.categoryName < cat2.categoryName
       }
    }
    
    func addNewTracker(_ tracker: Tracker) throws {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.returnsObjectsAsFaults = false
        
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCategoryCoreData.categoryID), tracker.category.id.uuidString)
        guard
            let categories = try? context.fetch(request),
            let category = categories.first
        else {
            throw TrackerStoreError.categoryNotFound
        }
        
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.trackerID = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.category = category
        trackerCoreData.createDate = Date()
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.colorHex = UIColorMarshalling.hexString(from: tracker.color)
        trackerCoreData.pinned = tracker.pinned
        
        if let habit = tracker as? Timetable {
            let trackerScheduleCoreData = TrackerScheduleCoreData(context: context)
            for weekDay in habit.getSchedule().repetition {
                switch weekDay {
                case .monday:
                    trackerScheduleCoreData.monday = true
                    break
                case .tuesday:
                    trackerScheduleCoreData.tuesday = true
                    break
                case .wednesday:
                    trackerScheduleCoreData.wednesday = true
                    break
                case .thursday:
                    trackerScheduleCoreData.thursday = true
                    break
                case .friday:
                    trackerScheduleCoreData.friday = true
                    break
                case .saturday:
                    trackerScheduleCoreData.saturday = true
                    break
                case .sunday:
                    trackerScheduleCoreData.sunday = true
                    break
                }
            }
            
            trackerCoreData.schedule = trackerScheduleCoreData
        }
        
        context.safeSave()
    }
    private func fetchTracker(_ trackerID: UUID) throws -> TrackerCoreData  {
        let request = TrackerCoreData.fetchRequest()
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCoreData.trackerID), trackerID.uuidString)
        
        guard let trackers = try? context.fetch(request) else {
            throw TrackerStoreError.getTrackerError
        }
        
        if trackers.count != 1 {
            throw TrackerStoreError.getTrackerError
        }
        
        return trackers[0]
    }
    
    func deleteTracker(_ tracker: Tracker) throws {
        context.delete(try fetchTracker(tracker.id))
        context.safeSave()
    }
    
    func updateTracker(_ trackerUpdate: Tracker) throws {
        let trackerCoreData = try fetchTracker(trackerUpdate.id)
        trackerCoreData.name = trackerUpdate.name
        trackerCoreData.emoji = trackerUpdate.emoji
        trackerCoreData.colorHex = UIColorMarshalling.hexString(from: trackerUpdate.color)
        trackerCoreData.pinned = trackerUpdate.pinned

        if let category = trackerCoreData.category, category.categoryID != trackerUpdate.category.id {
            let request = TrackerCategoryCoreData.fetchRequest()
            request.returnsObjectsAsFaults = false
            request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCategoryCoreData.categoryID), trackerUpdate.category.id.uuidString)
            
            guard let categories = try? context.fetch(request) else {
                throw TrackerStoreError.categoryNotFound
            }
            
            if categories.count < 1 || categories.count > 1 {
                throw TrackerStoreError.categoryNotFound
            }
            
            trackerCoreData.category = categories[0]
        }
        
        context.safeSave()
    }
        
    private func makeTracker(from trackerCoreData: TrackerCoreData, date: Date) throws -> TrackerViewModel {
        guard let trackerID = trackerCoreData.trackerID else {
            throw TrackerStoreError.decodingErrorInvalidId
        }
        guard let trackerName = trackerCoreData.name else {
            throw TrackerStoreError.decodingErrorInvalidName
        }
        guard let trackerEmoji = trackerCoreData.emoji else {
            throw TrackerStoreError.decodingErrorInvalidEmojies
        }
        guard let trackerColorHex = trackerCoreData.colorHex else {
            throw TrackerStoreError.decodingErrorInvalidColorHex
        }
        guard
            let categoryCoreData = trackerCoreData.category,
            let categoryID = categoryCoreData.categoryID,
            let categoryName = categoryCoreData.name
        else {
            throw TrackerStoreError.decodingErrorInvalidCategory
        }
        
        let tracker = Tracker(
            id: trackerID,
            name: trackerName,
            category: TrackerCategory(id: categoryID, name: categoryName),
            emoji: trackerEmoji,
            color: UIColorMarshalling.color(from: trackerColorHex),
            pinned: trackerCoreData.pinned
        )
                
        guard let records = trackerCoreData.records else {
            return TrackerViewModel(event: tracker, trackedDaysCount: 0, tracked: false)
        }
        
        var tracked = false
        for record in records.allObjects {
            if let trackerRecordCoreData = record as? TrackerRecordCoreData {
                if trackerRecordCoreData.date == Calendar.current.startOfDay(for: date) {
                    tracked = true
                }
            } else {
                print("failed to convert tarckerRecordCoreData")
            }
        }
        
        return TrackerViewModel(event: tracker, trackedDaysCount: records.count, tracked: tracked)
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        NotificationCenter.default.post(
            name: TrackerCollectionView.TrackerSavedNotification,
            object: nil
        )
    }
}
