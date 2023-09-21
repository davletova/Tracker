//
//  StatisticsViewModel.swift
//  Tracker
//
//  Created by Алия Давлетова on 18.09.2023.
//

import Foundation

protocol ListTrackerRecordsProtocol {
    func listRecords(withFilter: NSPredicate?, withSort: [NSSortDescriptor]) throws -> [TrackerRecordCoreData]
}

protocol ListScheduleProtocol {
    func listShedule() throws -> [TrackerScheduleCoreData]
}

protocol ListTrackerProtocol {
    func listTrackers(withFilter:  NSPredicate?, withSort: [NSSortDescriptor]) throws -> [TrackerCoreData]
}

final class StatisticsViewModel {
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
            if s.sunday {
                guard
                    let tracker = s.tracker,
                    let trackerID = tracker.trackerID
                else {
                    print("failed to get planned trackers by weekday \(Weekday.sunday)")
                    continue
                }
                
                if var foo = schedulesDict[1] {
                    foo.append(trackerID)
                    schedulesDict[1] = foo
                } else {
                    schedulesDict[1] = [trackerID]
                }
            }
            if s.monday {
                guard
                    let tracker = s.tracker,
                    let trackerID = tracker.trackerID
                else {
                    print("failed to get planned trackers by weekday \(Weekday.monday)")
                    continue
                }
                if var foo = schedulesDict[2] {
                    foo.append(trackerID)
                    schedulesDict[2] = foo
                } else {
                    schedulesDict[2] = [trackerID]
                }
            }
            if s.tuesday {
                guard
                    let tracker = s.tracker,
                    let trackerID = tracker.trackerID
                else {
                    print("failed to get planned trackers by weekday \(Weekday.tuesday)")
                    continue
                }
                if var foo = schedulesDict[3] {
                    foo.append(trackerID)
                    schedulesDict[3] = foo
                } else {
                    schedulesDict[3] = [trackerID]
                }
            }
            if s.wednesday {
                guard
                    let tracker = s.tracker,
                    let trackerID = tracker.trackerID
                else {
                    print("failed to get planned trackers by weekday \(Weekday.wednesday)")
                    continue
                }
                if var foo = schedulesDict[4] {
                    foo.append(trackerID)
                    schedulesDict[4] = foo
                } else {
                    schedulesDict[4] = [trackerID]
                }
            }
            if s.thursday {
                guard
                    let tracker = s.tracker,
                    let trackerID = tracker.trackerID
                else {
                    print("failed to get planned trackers by weekday \(Weekday.sunday)")
                    continue
                }
                if var foo = schedulesDict[5] {
                    foo.append(trackerID)
                    schedulesDict[5] = foo
                } else {
                    schedulesDict[5] = [trackerID]
                }
            }
            if s.friday {
                guard
                    let tracker = s.tracker,
                    let trackerID = tracker.trackerID
                else {
                    print("failed to get planned trackers by weekday \(Weekday.friday)")
                    continue
                }
                
                if var foo = schedulesDict[6] {
                    foo.append(trackerID)
                    schedulesDict[6] = foo
                } else {
                    schedulesDict[6] = [trackerID]
                }
            }
            if s.saturday {
                guard
                    let tracker = s.tracker,
                    let trackerID = tracker.trackerID
                else {
                    print("failed to get planned trackers by weekday \(Weekday.saturday)")
                    continue
                }
                
                if var foo = schedulesDict[7] {
                    foo.append(trackerID)
                    schedulesDict[7] = foo
                } else {
                    schedulesDict[7] = [trackerID]
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
        
        guard let record = records.first,
              let tracker = record.tracker
        else {
            print("failed to get tracker from records")
            return 0
        }
        
        var currentTrackerID = tracker.trackerID
        
        for i in 1..<records.count {
            guard let tracker = records[i].tracker else {
                print("failed to get tracker from records")
                return 0
            }
            
            if tracker.trackerID != currentTrackerID {
                currentTrackerID = tracker.trackerID
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
            withSort: []
        )
        
        let trackerIDsByWeekday = try getTrackerIDsByWeekday()
        
        var idealDaysCount = 0
        
        Dictionary(grouping: records) { record in
            guard let date = record.date else {
                assertionFailure("failed to get date from record")
                return Date()
            }
            return date
        }
            .forEach { (key: Date, value: [TrackerRecordCoreData]) in
                guard let weekday = Calendar.current.dateComponents([.weekday], from: key).weekday else {
                    assertionFailure("failed to get weekday")
                    return
                }
                if let trackersIDs = trackerIDsByWeekday[weekday],
                   value.count == trackersIDs.count {
                    idealDaysCount += 1
                }
            }
        
        return idealDaysCount
    }
    
    func getTotalPerformedHabits() throws -> Int {
        let trackers = try trackerStore.listTrackers(
            withFilter: NSPredicate(format: "%K != nil", #keyPath(TrackerCoreData.schedule)),
            withSort: []
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
            withSort:  []
        )
    
        let recordsByDate = Dictionary(grouping: records) { record in
            guard let date = record.date else {
                assertionFailure("failed to get date from record")
                return Date()
            }
            return date
        }
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
            withSort: []
        ).count
    }
}
