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

final class TrackerStore: NSObject, TrackerStoreProtocol, ListTrackerProtocol, TrackerModifierProtocol {
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
    
    private func getTracker(by id: UUID) throws -> TrackerCoreData  {
        let request = TrackerCoreData.fetchRequest()
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCoreData.trackerID), id.uuidString)
        request.fetchLimit = 1
        
        guard
            let results = try? context.fetch(request),
            let tracker = results.first
        else {
            throw TrackerStoreError.getTrackerError
        }
        
        return tracker
    }
    
    func listTrackers(withFilter:  NSPredicate?, withSort: [NSSortDescriptor]) throws -> [TrackerCoreData] {
        let request = TrackerCoreData.fetchRequest()
        
        if let predicate = withFilter {
            request.predicate = predicate
        }
        request.sortDescriptors = withSort
        return try context.fetch(request)
    }
    
    func makeSchedule(_ makeFunc: (TrackerScheduleCoreData) throws -> Void) throws -> TrackerScheduleCoreData {
        let trackerSchedule = TrackerScheduleCoreData(context: context)
        try makeFunc(trackerSchedule)
        return trackerSchedule
    }

    func createTracker(_ createFunc: (TrackerCoreData) throws -> Void) throws -> TrackerCoreData {
        let trackerCoreData = TrackerCoreData(context: context)
        try createFunc(trackerCoreData)

        context.safeSave()
        return trackerCoreData
    }
    
    func deleteTracker(by id: UUID) throws {
        context.delete(try getTracker(by: id))
        context.safeSave()
    }
    
    func updateTracker(by id: UUID, _ updateFunc: (TrackerCoreData) throws -> Void) throws {
        let tracker = try getTracker(by: id)
        try updateFunc(tracker)
        context.safeSave()
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        NotificationCenter.default.post(
            name: TrackersListViewController.TrackerSavedNotification,
            object: nil
        )
    }
}
