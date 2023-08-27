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
}

struct TrackerStoreUpdate {
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
    let updatedIndexes: IndexSet
}

protocol TrackerStoreDelegate: AnyObject {
    func store(
        _ store: TrackerStore,
        didUpdate update: TrackerStoreUpdate
    )
}

final class TrackerStore: NSObject {
    private let uiColorMarshalling = UIColorMarshalling()
    private let context: NSManagedObjectContext
    
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    private var updatedIndexes: IndexSet?

    private var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>!
    
    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        try! self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) throws {
        self.context = context
        super.init()
        
        let fetchRequest = TrackerCoreData.fetchRequest()
//        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        fetchRequest.sortDescriptors = [
//            NSSortDescriptor(key: "category", ascending: true),
            NSSortDescriptor(key: "createDate", ascending: true)
        ]
        
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: "category",
            cacheName: nil
        )
        
        controller.delegate = self
        self.fetchedResultsController = controller
        try? controller.performFetch()
    }
    
    
    func getTrackers(by date: Date) -> [TrackersByCategory] {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.returnsObjectsAsFaults = false
        // request.predicate = NSPredicate(format: "%K == nil", #keyPath(TrackerCoreData.schedule))
        
        let dayOfWeek = String(describing: date.dayNumberOfWeek())
        request.predicate = NSCompoundPredicate.init(type: .or, subpredicates: [
            NSCompoundPredicate.init(type: .and, subpredicates: [
                NSPredicate(format: "%K != nil", #keyPath(TrackerCoreData.schedule)),
                NSPredicate(format: "%K.\(dayOfWeek) = true", #keyPath(TrackerCoreData.schedule)),
            ]),
            NSPredicate(format: "%K == nil", #keyPath(TrackerCoreData.schedule))
        ])
        
        let trackers = try! context.fetch(request)
        let trackersByCategory = Dictionary(grouping: trackers) { (tracker) -> String in
            return tracker.category!.name!
        }
        
        return trackersByCategory.map { (categoryName: String, trackersManaged: [TrackerCoreData]) in
            let trackers = try! trackersManaged.map { trackerManaged in
                guard let baz = try? makeTracker(from: trackerManaged) else {
                    throw TrackerStoreError.categoryNotFound
                }
                return baz
            }

            return TrackersByCategory(categoryName: categoryName, trackers: trackers)
        }
        
//        let request = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
//        request.returnsObjectsAsFaults = false
//
//        // request.predicate = NSPredicate(format: "%K = true", #keyPath(TrackerCoreData.schedule.monday))
//
//        let categories = try! context.fetch(request)
//        return categories.map { trackerCategoryCoreData in
//            let trackers = try! trackerCategoryCoreData.trackers?.allObjects.filter { qqq in
//                guard let foo = qqq as? TrackerCoreData else {
//                    throw TrackerStoreError.categoryNotFound
//                }
//
//                guard let schedule = foo.schedule else {
//                    return true
//                }
//
//                guard let dayOfWeek = date.dayNumberOfWeek() else {
//                    print("failed to get day of week")
//                    return [TrackersByCategory]()
//                }
//
//                date.
//                schedule
//
//                guard let baz = try? makeTracker(from: foo) else {
//                    throw TrackerStoreError.categoryNotFound
//                }
//                return baz
//            }
//            return TrackersByCategory(categoryName: trackerCategoryCoreData.name!, trackers: trackers!)
//        }
    }
    
    func addNewTracker(_ tracker: Tracker) throws {
        let request = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCategoryCoreData.name), tracker.category.name)
        
        var categories = try! context.fetch(request)
        if categories.isEmpty {
            // временный код добавления категорий
            // пока не создан модуль создания категорий
            let trackerCategoryCoreData = TrackerCategoryCoreData(context: context)
            trackerCategoryCoreData.name = tracker.category.name
            categories = try! context.fetch(request)
//            throw TrackerStoreError.categoryNotFound
            
            
        }
                
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.category = categories[0]
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
        
        do {
            try context.save()
        } catch {
            print("=========  dfsdfd  =+========")
        }
        
    }
        
    private func makeTracker(from trackerCoreData: TrackerCoreData) throws -> Tracker {
        guard let trackerId = trackerCoreData.id else {
            throw TrackerStoreError.decodingErrorInvalidId
        }
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
        return Tracker(
            id: trackerId,
            name: trackerName,
            category: trackerCategory,
            emoji: trackerEmoji,
            color: uiColorMarshalling.color(from: trackerColorHex)
        )
    }
    
    private func makeTrackerCategory(from categoryCoreData: TrackerCategoryCoreData) throws -> TrackerCategory {
        guard let categoryName = categoryCoreData.name else {
            throw TrackerStoreError.decodingErrorInvalidCategoryName
        }
        return TrackerCategory(name: categoryName)
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
        updatedIndexes = IndexSet()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        NotificationCenter.default.post(
            name: TrackerCollectionView.TrackerSavedNotification,
            object: self,
            userInfo: ["event": TrackerStoreUpdate(
                insertedIndexes: insertedIndexes!,
                deletedIndexes: deletedIndexes!,
                updatedIndexes: updatedIndexes!
            )]
        )
        insertedIndexes = nil
        deletedIndexes = nil
        updatedIndexes = nil
    }
}
