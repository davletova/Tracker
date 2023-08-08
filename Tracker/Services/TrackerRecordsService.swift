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
    static let AddEventNotification = Notification.Name(rawValue: "AddEvent")
    static let DeleteEventNotification = Notification.Name(rawValue: "DeleteEvent")
    
    var trackerRecords: [TrackerRecord] = mockTrackerRecords
    
    init() {
        let serialQueue = DispatchQueue(label: "serialQueue")
        
        NotificationCenter.default.addObserver(
            forName: TrackerRecordService.AddEventNotification,
            object: nil,
            queue: OperationQueue.main
        ) { record in
            guard let record = record.object as? TrackerRecord else {
                print("failed to convert notification: \(record) to TrackerRecord")
                return
            }
            
            self.addRecords(record: record)
        }
        
        NotificationCenter.default.addObserver(
            forName: TrackerRecordService.DeleteEventNotification,
            object: nil,
            queue: OperationQueue.main
        ) { record in
            guard let record = record.object as? TrackerRecord else {
                print("failed to convert notification: \(record) to TrackerRecord")
                return
            }
            
            self.deleteTrackerRecord(record: record)
        }
    }
    
    func getRecordsByDate(date: Date) -> [TrackerRecord] {
        var result = [TrackerRecord]()
        
        for record in trackerRecords {
            if let isDateRight = record.date.inDay(day: date),
               isDateRight {
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
            
            guard let isDateRight = trackerRecords[i].date.inDay(day: record.date) else {
                return
            }
            if isDateRight {
                trackerRecords.remove(at: i)
            }
        }
    }
}
