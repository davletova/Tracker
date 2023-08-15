//
//  TrackerService.swift
//  Tracker
//
//  Created by Алия Давлетова on 05.08.2023.
//

import Foundation

protocol TrackerServiceProtocol {
    func getEvents(by date: Date) -> [Section]
    
    func getCompletedEvents(by date: Date) -> Set<UUID>
    
    func createEvent(event: Event)
    
    func updateEvent(event: Event) -> Event?
    
    func deleteEvent(eventID: UUID)
}

protocol TrackerRecordServiceProtocol {
    func getRecords(by date: Date) -> [TrackerRecord]
}

struct Section {
    var categoryName: String
    var events: [Event]
}

final class TrackerService: TrackerServiceProtocol {
    static let TrackEventNotification = Notification.Name(rawValue: "trackEvent")

    var events = [UUID: Event]()
    
    var trackerRecordService: TrackerRecordServiceProtocol
    
    init(trackerRecordService: TrackerRecordServiceProtocol) {
        self.trackerRecordService = trackerRecordService
    
        events = createMockEvents()
        
        NotificationCenter.default.addObserver(
            forName: TrackerRecordService.AddTrackerRecordNotification,
            object: nil,
            queue: OperationQueue.main
        ) { record in
            guard let record = record.userInfo?["record"] as? TrackerRecord else {
                print("failed to convert notification: \(record) to TrackerRecord")
                return
            }
            
            self.trackEvent(eventId: record.eventID)
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
            
            self.untrackEvent(eventId: record.eventID)
        }
    }

    func getEvents(by date: Date) -> [Section] {
        let startOfDate = Calendar.current.startOfDay(for: date)
        
        var eventsByDate = [UUID: Event]()
        
        guard let dayOfWeek = date.dayNumberOfWeek() else {
            print("failed to get day of week")
            return [Section]()
        }
        
        for (_, event) in events {
            if let habit = event as? Timetable {
                if !habit.getSchedule().repetition.contains(dayOfWeek) {
                    continue
                }
            }
            eventsByDate[event.id] = event
        }
                
        let completedEvents = getCompletedEvents(by: date)
        
        for eventId in completedEvents {
            guard let event = events[eventId] else {
                print("event with id \(eventId) not found")
                continue
            }
            
            eventsByDate.updateValue(event, forKey: eventId)
        }
        
        return putEventsToSections(cellEvents: eventsByDate)
    }
    
    func getCompletedEvents(by date: Date) -> Set<UUID> {
        var completedEvents = Set<UUID>()
        
        for record in trackerRecordService.getRecords(by: date) {
            completedEvents.insert(record.eventID)
        }
        
        return completedEvents
    }
    
    
    func createEvent(event: Event) {
        events.updateValue(event, forKey: event.id)
    }
    
    func updateEvent(event updateEvent: Event) -> Event? {
        events.updateValue(updateEvent, forKey: updateEvent.id)
    
        return events[updateEvent.id]
    }
    
    func deleteEvent(eventID: UUID) {
        events.removeValue(forKey: eventID)
    }
    
    func trackEvent(eventId: UUID) {
        guard let event = events[eventId] else {
            print("event with id \(eventId) not found")
            return
        }
        
        event.trackedDaysCount += 1
        events[eventId] = event
    }
    
    func untrackEvent(eventId: UUID) {
        guard let event = events[eventId] else {
            print("event with id \(eventId) not found")
            return
        }
        
        event.trackedDaysCount -= 1
        if event.trackedDaysCount == -1 {
            event.trackedDaysCount = 0
        }
        events[eventId] = event
    }
    
    func putEventsToSections(cellEvents: [UUID: Event]) -> [Section] {
        var sectionsDictionary = [String: [Event]]()
        var sections = [Section]()
    
        for (_, event) in cellEvents  {
            guard var sectionEvents = sectionsDictionary[event.category.name] else {
                sectionsDictionary[event.category.name] = [event]
                continue
            }
            
            sectionEvents.append(event)
            sectionsDictionary[event.category.name] = sectionEvents
        }
        
        for (categoryName, sectionEvents) in sectionsDictionary {
            sections.append(Section(categoryName: categoryName, events: sectionEvents))
        }
    
        return sections
    }
}

//func dateFromString(date: String) -> Date {
//    let dateFormatter = DateFormatter()
//    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
//    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
//    return dateFormatter.date(from: date)!
//
//}
//let d1 = dateFromString(date: "2023-08-07T02:44:00")
//let d2 = dateFromString(date: "2023-08-06T21:44:00")
//let d3 = Date()
//let newDate = Calendar.current.date(byAdding: .day, value: 1, to: d3)
//let date = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: newDate!)!
//
//print(date.formatted(date: .abbreviated, time: .standard))
//print(date > Date())
