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
    
    func listTrackerRecords() throws -> Int {
        let request = TrackerRecordCoreData.fetchRequest()
        let records = try context.fetch(request)

        var bestContinousDays = 1
        Dictionary(grouping: records) { $0.tracker?.id }
            .values
            .forEach { (values: [TrackerRecordCoreData]) in
                var v = values
                v.sort(by: { $0.date! < $1.date! })
                
                var continousDays = 1
                for i in 1..<v.count {
                    guard let prevDate = v[i-1].date,
                          let currDate = v[i].date
                    else {
                        continue
                    }
                    
                    if let diffDays = Calendar.current.dateComponents([.day], from: prevDate, to: currDate).day {
                        if diffDays > 1  {
                            bestContinousDays = max(bestContinousDays, continousDays)
                            continousDays = 1

                            continue
                        }
                        
                        continousDays += 1
                    }
                    
                    bestContinousDays = max(bestContinousDays, continousDays)
                }
            }
        return bestContinousDays
    }
    
    func idealDaysBlya() throws -> Int {
        let getScheduleRequest = TrackerScheduleCoreData.fetchRequest()
        let schedules = try context.fetch(getScheduleRequest)
        
        var dict = [Int: [UUID]]()
        
        for s in schedules {
            //TODO: убрать force unwrap
            if s.sunday {
                if var foo = dict[1] {
                    foo.append(s.tracker!.trackerID!)
                    dict[1] = foo
                } else {
                    dict[1] = [s.tracker!.trackerID!]
                }
            }
            if s.monday {
                if var foo = dict[2] {
                    foo.append(s.tracker!.trackerID!)
                    dict[2] = foo
                } else {
                    dict[2] = [s.tracker!.trackerID!]
                }
            }
            if s.tuesday {
                if var foo = dict[3] {
                    foo.append(s.tracker!.trackerID!)
                    dict[3] = foo
                } else {
                    dict[3] = [s.tracker!.trackerID!]
                }
            }
            if s.wednesday {
                if var foo = dict[4] {
                    foo.append(s.tracker!.trackerID!)
                    dict[4] = foo
                } else {
                    dict[4] = [s.tracker!.trackerID!]
                }
            }
            if s.thursday {
                if var foo = dict[5] {
                    foo.append(s.tracker!.trackerID!)
                    dict[5] = foo
                } else {
                    dict[5] = [s.tracker!.trackerID!]
                }
            }
            if s.friday {
                if var foo = dict[6] {
                    foo.append(s.tracker!.trackerID!)
                    dict[6] = foo
                } else {
                    dict[6] = [s.tracker!.trackerID!]
                }
            }
            if s.saturday {
                if var foo = dict[7] {
                    foo.append(s.tracker!.trackerID!)
                    dict[7] = foo
                } else {
                    dict[7] = [s.tracker!.trackerID!]
                }
            }
        }
        
        let request = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "%K != nil", #keyPath(TrackerScheduleCoreData.tracker.schedule))
        let records = try context.fetch(request)

        var idealDaysCount = 0
        
        // data: records
        Dictionary(grouping: records) { $0.date! }
            .forEach { (key: Date, value: [TrackerRecordCoreData]) in
                let weekday = Calendar.current.dateComponents([.weekday], from: key).weekday!
                if value.count == dict[weekday]?.count {
                    idealDaysCount += 1
                }
            }
        
        return idealDaysCount
    }
    
    func getTotalPerformedHabits() throws -> Int {
        let request = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "%K != nil", #keyPath(TrackerCoreData.schedule))
        let trackers = try context.fetch(request)

        var totalPerformedHabits = 0
        
        trackers.forEach { tracker in
            if let records = tracker.records,
               records.count > 0
            {
                totalPerformedHabits += 1
            }
        }
        
        return totalPerformedHabits
    }
    
    func getAverrage() throws -> Int {
        let request = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "%K != nil", #keyPath(TrackerScheduleCoreData.tracker.schedule))
        let records = try context.fetch(request)

        var idealDaysCount = 0
        
        // data: records
        let dict = Dictionary(grouping: records) { $0.date! }
        let totalDays = dict.keys.count
        
        var totalTracked = 0
        
        dict.forEach { (_: Date, value: [TrackerRecordCoreData])  in
                totalTracked += value.count
            }
        
        return Int(round(Double(totalTracked)/Double(totalDays)))
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

