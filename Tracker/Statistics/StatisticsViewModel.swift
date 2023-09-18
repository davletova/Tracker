//
//  StatisticsViewModel.swift
//  Tracker
//
//  Created by Алия Давлетова on 18.09.2023.
//

import Foundation

protocol ListTrackerRecordsProtocol {
    func listRecords(withFilter: NSPredicate?, withSort: [NSSortDescriptor]?) throws -> [TrackerRecordCoreData]
}

protocol ListScheduleProtocol {
    func listShedule() throws -> [TrackerScheduleCoreData]
}

protocol ListTrackerProtocol {
    func listTrackers(withFilter:  NSPredicate?, withSort: [NSSortDescriptor]?) throws -> [TrackerCoreData]
}

final class StatisticsViewModel {
    //TODO: use protocol
    let recordStore: ListTrackerRecordsProtocol
    let scheduleStore: ListScheduleProtocol
    let trackerStore: ListTrackerProtocol
    
    init(
        recordStore: ListTrackerRecordsProtocol,
        scheduleStore: ListScheduleProtocol,
        trackerStore: ListTrackerProtocol
    ) {
        self.recordStore = recordStore
        self.scheduleStore = scheduleStore
        self.trackerStore = trackerStore
    }
    
    private func getTrackerIDsByWeekday() throws -> [Int: [UUID]] {
        let schedules = try scheduleStore.listShedule()
        
        var schedulesDict = [Int: [UUID]]()
        
        for s in schedules {
            //TODO: убрать force unwrap
            if s.sunday {
                if var foo = schedulesDict[1] {
                    foo.append(s.tracker!.trackerID!)
                    schedulesDict[1] = foo
                } else {
                    schedulesDict[1] = [s.tracker!.trackerID!]
                }
            }
            if s.monday {
                if var foo = schedulesDict[2] {
                    foo.append(s.tracker!.trackerID!)
                    schedulesDict[2] = foo
                } else {
                    schedulesDict[2] = [s.tracker!.trackerID!]
                }
            }
            if s.tuesday {
                if var foo = schedulesDict[3] {
                    foo.append(s.tracker!.trackerID!)
                    schedulesDict[3] = foo
                } else {
                    schedulesDict[3] = [s.tracker!.trackerID!]
                }
            }
            if s.wednesday {
                if var foo = schedulesDict[4] {
                    foo.append(s.tracker!.trackerID!)
                    schedulesDict[4] = foo
                } else {
                    schedulesDict[4] = [s.tracker!.trackerID!]
                }
            }
            if s.thursday {
                if var foo = schedulesDict[5] {
                    foo.append(s.tracker!.trackerID!)
                    schedulesDict[5] = foo
                } else {
                    schedulesDict[5] = [s.tracker!.trackerID!]
                }
            }
            if s.friday {
                if var foo = schedulesDict[6] {
                    foo.append(s.tracker!.trackerID!)
                    schedulesDict[6] = foo
                } else {
                    schedulesDict[6] = [s.tracker!.trackerID!]
                }
            }
            if s.saturday {
                if var foo = schedulesDict[7] {
                    foo.append(s.tracker!.trackerID!)
                    schedulesDict[7] = foo
                } else {
                    schedulesDict[7] = [s.tracker!.trackerID!]
                }
            }
        }
        
        return schedulesDict
    }
}
extension StatisticsViewModel: StatisticsViewModelProtocol {
    func getBestPeriod() throws -> Int {
        let records = try recordStore.listRecords(
            withFilter: nil,
            withSort: [
                NSSortDescriptor(key: "tracker.trackerID", ascending: true),
                NSSortDescriptor(key: "date", ascending: true),
            ]
        )
        
        if records.count == 0 {
            return 0
        }
        
        var bestContinousDays = 1
        var bestContinousDaysForTracker = 1
        //TODO: fix force unwrap
        var currentTrackerID = records.first!.tracker!.trackerID
        
        for i in 1..<records.count {
            if records[i].tracker!.trackerID != currentTrackerID {
                currentTrackerID = records[i].tracker!.trackerID
                bestContinousDays = max(bestContinousDays, bestContinousDaysForTracker)
                bestContinousDaysForTracker = 1
                continue
            }
            
            guard let prevDate = records[i-1].date,
                  let currDate = records[i].date,
                  let diffDays = Calendar.current.dateComponents([.day], from: prevDate, to: currDate).day,
                  diffDays > 1
            else {
                bestContinousDays = max(bestContinousDays, bestContinousDaysForTracker)
                bestContinousDaysForTracker = 1
                continue
            }
            
            bestContinousDaysForTracker += 1
        }
    
        return max(bestContinousDays, bestContinousDaysForTracker)
    }
    
    func getCountOfIdealDays() throws -> Int {
        let records = try recordStore.listRecords(
            withFilter: NSPredicate(format: "%K != nil", #keyPath(TrackerRecordCoreData.tracker.schedule)),
            withSort: nil
        )
        
        let trackerIDsByWeekday = try getTrackerIDsByWeekday()
        
        var idealDaysCount = 0
        
        Dictionary(grouping: records) { $0.date! }
            .forEach { (key: Date, value: [TrackerRecordCoreData]) in
                let weekday = Calendar.current.dateComponents([.weekday], from: key).weekday!
                if value.count == trackerIDsByWeekday[weekday]?.count {
                    idealDaysCount += 1
                }
            }
        
        return idealDaysCount
    }
    
    func getTotalPerformedHabits() throws -> Int {
        let trackers = try trackerStore.listTrackers(
            withFilter: NSPredicate(format: "%K != nil", #keyPath(TrackerCoreData.schedule)),
            withSort: nil
        )
        
        var totalPerformedHabits = 0
        
        trackers.forEach { tracker in
            if let records = tracker.records, records.count > 0 {
                totalPerformedHabits += 1
            }
        }
        
        return totalPerformedHabits
    }
    
    func getAverrage() throws -> Int {
        let records = try recordStore.listRecords(
            withFilter: NSPredicate(format: "%K != nil", #keyPath(TrackerRecordCoreData.tracker.schedule)),
            withSort:  nil
        )
    
        let recordsByDate = Dictionary(grouping: records) { $0.date! }
        let totalDays = recordsByDate.keys.count
        
        var totalTracked = 0
        
        recordsByDate.forEach { (_: Date, value: [TrackerRecordCoreData]) in
            totalTracked += value.count
        }
        
        if totalTracked == 0 {
            return 0
        }
        
        return Int(round(Double(totalTracked)/Double(totalDays)))
    }
    
    func getTrackersCount() throws -> Int {
        return try trackerStore.listTrackers(
            withFilter: nil,
            withSort: nil
        ).count
    }
}
