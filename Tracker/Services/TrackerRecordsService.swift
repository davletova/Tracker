//
//  TrackerRecordsService.swift
//  Tracker
//
//  Created by Алия Давлетова on 06.08.2023.
//

import Foundation

struct TrackerRecord {
    let eventID: UUID
    
    let date: Date
}

final class TrackerRecordService: TrackerRecordServiceProtocol {
    static let AddTrackerRecordNotification = Notification.Name(rawValue: "AddRecordTracker")
    static let DeleteTrackerRecordNotification = Notification.Name(rawValue: "DeleteEvent")
    
    var trackerRecords: [TrackerRecord] = mockTrackerRecords
    
    init() {
        NotificationCenter.default.addObserver(
            forName: TrackerRecordService.AddTrackerRecordNotification,
            object: nil,
            queue: OperationQueue.main
        ) { record in
            guard let record = record.userInfo?["record"] as? TrackerRecord else {
                print("failed to convert notification: \(record) to TrackerRecord")
                return
            }
            
            self.addRecords(record: record)
        }
        
        NotificationCenter.default.addObserver(
            forName: TrackerRecordService.DeleteTrackerRecordNotification,
            object: nil,
            queue: OperationQueue.main
        ) { record in
            guard let record = record.userInfo?["record"] as? TrackerRecord else {
                print("failed to convert notification: \(record) to TrackerRecord")
                return
            }
            
            self.deleteTrackerRecord(record: record)
        }
    }
    
    func getRecords(by date: Date) -> [TrackerRecord] {
        var result = [TrackerRecord]()
        let startDate = Calendar.current.startOfDay(for: date)
        
        for record in trackerRecords {
            print("record date: \(record.date.description)")
            print("date: \(startDate.description)")
            if record.date == startDate {
                result.append(record)
            }
        }
        
        print("records: /n \(result)")
        
        return result
    }
    
    private func addRecords(record: TrackerRecord) {
        trackerRecords.append(record)
    }
    
    private func deleteTrackerRecord(record: TrackerRecord) {
        for i in (0..<trackerRecords.count).reversed() {
            if trackerRecords[i].eventID != record.eventID {
                continue
            }
            
            guard let isDateRight = trackerRecords[i].date.inDay(day: record.date) else {
                return
            }
            if isDateRight {
                trackerRecords.remove(at: i)
            }
        }
    }
}
