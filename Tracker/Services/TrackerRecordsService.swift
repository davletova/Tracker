//
//  TrackerRecordsService.swift
//  Tracker
//
//  Created by Алия Давлетова on 06.08.2023.
//

import Foundation

protocol TrackerRecordServiceProtocol {
    func getRecords(by date: Date) -> [TrackerRecord]
    func getSetOfCOmpletedEvents(by date: Date) -> Set<UUID>
    func getTrackerDaysCount(of eventId: UUID) -> Int
    
    func addRecords(record: TrackerRecord)
    func deleteTrackerRecord(record: TrackerRecord)
}

final class TrackerRecordService: TrackerRecordServiceProtocol {
    var trackerRecords = [TrackerRecord]()
    
    func getRecords(by date: Date) -> [TrackerRecord] {
        var result = [TrackerRecord]()
        let startDate = Calendar.current.startOfDay(for: date)
        
        for record in trackerRecords {
            if record.date == startDate {
                result.append(record)
            }
        }
        
        return result
    }
    
    func getTrackerDaysCount(of eventId: UUID) -> Int {
        var trackerDaysCount = 0
        
        for record in trackerRecords {
            if record.eventID == eventId {
                trackerDaysCount += 1
            }
        }
        
        return trackerDaysCount
    }
    
    func getSetOfCOmpletedEvents(by date: Date) -> Set<UUID> {
        var completedEvents = Set<UUID>()
        var recordsByDate = getRecords(by: date)
        
        for record in recordsByDate {
            completedEvents.insert(record.eventID)
        }
        
        return completedEvents
    }
    
    func addRecords(record: TrackerRecord) {
        trackerRecords.append(record)
    }
    
    func deleteTrackerRecord(record: TrackerRecord) {
        for i in (0..<trackerRecords.count).reversed() {
            if trackerRecords[i].eventID != record.eventID {
                continue
            }
            if trackerRecords[i].date == record.date {
                trackerRecords.remove(at: i)
                break
            }
        }
    }
}
