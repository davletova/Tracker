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

final class TrackerRecordStore: NSObject, TrackerRecordStoreProtocol {
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
        let request = TrackerCoreData.fetchRequest()
        
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCoreData.trackerID), trackerRecord.eventID.uuidString)
        guard let trackers = try? context.fetch(request) else {
            throw TrackerRecordStoreError.getTrackerError
        }
        if trackers.count < 1 || trackers.count > 1 {
            throw TrackerRecordStoreError.getTrackerError
        }
        
        let trackerRecordCoreData = TrackerRecordCoreData(context: context)
        trackerRecordCoreData.date = trackerRecord.date
        trackerRecordCoreData.tracker = trackers[0]

        context.safeSave()
    }
    
    func deleteRecord(_ trackerRecord: TrackerRecord) throws {
        let request = TrackerCoreData.fetchRequest()
        request.returnsObjectsAsFaults = false
        
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCoreData.trackerID), trackerRecord.eventID.uuidString)
        guard let trackers = try? context.fetch(request) else {
            throw TrackerRecordStoreError.getTrackerError
        }
        if trackers.count < 1 || trackers.count > 1 {
            throw TrackerRecordStoreError.getTrackerError
        }
        
        guard let records = trackers[0].records else {
            print("failed to get records for tracker \(String(describing: trackers[0].name))")
            throw TrackerRecordStoreError.getRecordError
        }
        
        let dateEqualPredicate = NSPredicate(format: "%K == %@", #keyPath(TrackerRecordCoreData.date), Calendar.current.startOfDay(for: trackerRecord.date) as NSDate)
        let filteredRecords = records.filtered(using: dateEqualPredicate)
        
        if filteredRecords.count < 1 || filteredRecords.count > 1 {
            throw TrackerRecordStoreError.getRecordError
        }
        guard let trackerRecordCoreData = filteredRecords.first as? TrackerRecordCoreData else {
            throw TrackerRecordStoreError.decodeRecordError
        }
        
        context.delete(trackerRecordCoreData)
        context.safeSave()
    }
}

extension TrackerRecordStore: ListTrackerRecordsProtocol {
    func listRecords(withFilter:  NSPredicate?, withSort: [NSSortDescriptor]) throws -> [TrackerRecordCoreData] {
        let request = TrackerRecordCoreData.fetchRequest()
        if let predicate = withFilter {
            request.predicate = predicate
        }
        request.sortDescriptors = withSort
        return try context.fetch(request)
    }
}
