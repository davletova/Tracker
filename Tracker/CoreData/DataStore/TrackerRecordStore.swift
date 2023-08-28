//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Алия Давлетова on 25.08.2023.
//

import Foundation
import CoreData
import UIKit

enum TrackerRecordStoreError: Error {
    case getTrackerError
    case getTrackerIDError
    case trackerNotFound
    case getRecordError
    case recordNotFound
    case generateURLError
    case decodeRecordError
    case decodeTrackerError
}

struct TrackerRecordStoreUpdate {
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
}

final class TrackerRecordStore: NSObject {
    private let context: NSManagedObjectContext
    
    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        try! self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) throws {
        self.context = context
        super.init()
    }
    
    func addNewRecord(_ trackerRecord: TrackerRecord) throws {
        guard let id = URL(string: trackerRecord.eventID) else {
            throw TrackerRecordStoreError.generateURLError
        }
        
        guard let objectId = context.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: id) else {
            throw TrackerRecordStoreError.getTrackerIDError
        }
        
        guard let tracker = try? context.existingObject(with: objectId) else {
            throw TrackerRecordStoreError.getTrackerError
        }
        guard let trackerCoreData = tracker as? TrackerCoreData else {
            throw TrackerRecordStoreError.decodeTrackerError
        }
        
        let trackerRecordCoreData = TrackerRecordCoreData(context: context)
        trackerRecordCoreData.date = trackerRecord.date
        trackerRecordCoreData.tracker = trackerCoreData
        
        context.safeSave()
    }
    
    func deleteRecord(_ trackerRecord: TrackerRecord) throws {
        guard let id = URL(string: trackerRecord.eventID) else {
            throw TrackerRecordStoreError.generateURLError
        }
        
        guard let objectId = context.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: id) else {
            throw TrackerRecordStoreError.getTrackerIDError
        }
        
        guard let tracker = try context.existingObject(with: objectId) as? TrackerCoreData else {
            throw TrackerRecordStoreError.getTrackerError
        }
        
        guard let records = tracker.records else {
            print("failed to get records for tracker \(tracker.name)")
            throw TrackerRecordStoreError.getRecordError
        }
        
        let dateEqualPredicate = NSPredicate(format: "%K == %@", #keyPath(TrackerRecordCoreData.date), Calendar.current.startOfDay(for: trackerRecord.date) as NSDate)
        var record = records.filtered(using: dateEqualPredicate)
        
        if record.isEmpty {
            throw TrackerRecordStoreError.recordNotFound
        }
        guard let trackerRecordCoreData = record.popFirst() as? TrackerRecordCoreData else {
            throw TrackerRecordStoreError.decodeRecordError
        }
        
        context.delete(trackerRecordCoreData)
    }
}

