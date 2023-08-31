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
}

struct TrackerStoreUpdate {
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
    let updatedIndexes: IndexSet
}

final class TrackerStore: NSObject, TrackerStoreProtocol {
    private let uiColorMarshalling = UIColorMarshalling()
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
        try? fetchedResultsController.performFetch()
    }
    
    func getTrackers(by date: Date, withName name: String? = nil) -> [TrackersByCategory] {
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
            print("")
            return [TrackersByCategory]()
        }
        let trackersByCategoryDictionary = Dictionary(grouping: trackers) { (tracker) -> String in
            
            return tracker.category!.name!
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
        }.sorted(by: {$0.categoryName < $1.categoryName } )
    }
    
    func addNewTracker(_ tracker: Tracker) throws {
        guard
            let id = tracker.category.id,
            let idString = URL(string: id)
        else {
            throw TrackerStoreError.generateURLError
        }
        
        guard let objectId = context.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: idString) else {
            throw TrackerStoreError.categoryNotFound
        }
        
        guard let category = try context.existingObject(with: objectId) as? TrackerCategoryCoreData else {
            throw TrackerStoreError.decodingErrorInvalidCategory
        }
        
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.name = tracker.name
        trackerCoreData.category = category
        trackerCoreData.createDate = Date()
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.colorHex = uiColorMarshalling.hexString(from: tracker.color)
        
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
        
    private func makeTracker(from trackerCoreData: TrackerCoreData, date: Date) throws -> TrackerViewModel {
        guard let trackerName = trackerCoreData.name else {
            throw TrackerStoreError.decodingErrorInvalidName
        }
        guard
            let trackerCategoryCoreData = trackerCoreData.category,
            let trackerCategory = try? makeTrackerCategory(from: trackerCategoryCoreData)
        else {
            throw TrackerStoreError.decodingErrorInvalidCategory
        }
        guard let trackerEmoji = trackerCoreData.emoji else {
            throw TrackerStoreError.decodingErrorInvalidEmojies
        }
        guard let trackerColorHex = trackerCoreData.colorHex else {
            throw TrackerStoreError.decodingErrorInvalidColorHex
        }
        let tracker = Tracker(
            name: trackerName,
            category: trackerCategory,
            emoji: trackerEmoji,
            color: uiColorMarshalling.color(from: trackerColorHex)
        )
        tracker.id = trackerCoreData.objectID.uriRepresentation().absoluteString
        
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
    
    private func makeTrackerCategory(from categoryCoreData: TrackerCategoryCoreData) throws -> TrackerCategory {
        guard let categoryName = categoryCoreData.name else {
            throw TrackerStoreError.decodingErrorInvalidCategoryName
        }
        return TrackerCategory(name: categoryName)
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        NotificationCenter.default.post(
            name: TrackerCollectionView.TrackerSavedNotification,
            object: self
        )
    }
}
