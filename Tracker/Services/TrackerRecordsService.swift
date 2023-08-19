//
//  TrackerRecordsService.swift
//  Tracker
//
//  Created by Алия Давлетова on 06.08.2023.
//

import Foundation

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
            if record.date == startDate {
                result.append(record)
            }
        }
        
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
            if trackerRecords[i].date == record.date {
                trackerRecords.remove(at: i)
                break
            }
        }
    }
}
