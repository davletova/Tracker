//
//  TrackerService.swift
//  Tracker
//
//  Created by Алия Давлетова on 05.08.2023.
//

import Foundation

protocol TrackerServiceProtocol {
    func getEvents(by date: Date) -> [Section]
    func filterEvents(by name: String, date: Date) -> [Section]
    func getCompletedEvents(by date: Date) -> Set<UUID>
    func createEvent(event: Event)
    func updateEvent(event: Event) -> Event?
    func deleteEvent(eventID: UUID)
    func trackEvent(eventId: UUID)
    func untrackEvent(eventId: UUID)
}

protocol TrackerRecordServiceProtocol {
    func getRecords(by date: Date) -> [TrackerRecord]
}

struct Section {
    var categoryName: String
    var events: [Event]
}

final class TrackerService {
    static let CreateEventNotification = Notification.Name(rawValue: "creatEvent")
    
    var events = [UUID: Event]()
    
    var trackerRecordService: TrackerRecordServiceProtocol
    
    init(trackerRecordService: TrackerRecordServiceProtocol) {
        self.trackerRecordService = trackerRecordService
        
        events = createMockEvents()
        
        NotificationCenter.default.addObserver(
            forName: TrackerService.CreateEventNotification,
            object: nil,
            queue: OperationQueue.main
        ) { [weak self] notification in
            guard let self = self else {
                print("TrackerService, CreateEventNotification: self is empty")
                return
            }
            
            guard let event = notification.userInfo?["event"] as? Event else {
                print("failed to convert event: \(String(describing: notification.userInfo?["event"]))")
                return
            }
            
            self.createEvent(event: event)
        }
    }
}

extension TrackerService: TrackerServiceProtocol {
    func getEvents(by date: Date) -> [Section] {
        var eventsByCategory = [String: [Event]]()
        
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
            
            if var categoryEvents = eventsByCategory[event.category.name] {
                categoryEvents.append(event)
                eventsByCategory[event.category.name] = categoryEvents
            } else {
                eventsByCategory[event.category.name] = [event]
            }
        }
        
        return putEventsToSections(eventsByCategory: eventsByCategory)
    }
    
    func filterEvents(by name: String, date: Date) -> [Section] {
        var eventsByDate = getEvents(by: date)
        
        for i in (0..<eventsByDate.count).reversed() {
            eventsByDate[i].events = eventsByDate[i].events.filter({ $0.name.lowercased().contains(name.lowercased()) })
            
            if eventsByDate[i].events.isEmpty {
                eventsByDate.remove(at: i)
            }
        }
        
        return eventsByDate
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
        
        NotificationCenter.default.post(
            name: TrackerCollectionView.EventSavedNotification,
            object: self,
            userInfo: ["event": event]
        )
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
    
    private func putEventsToSections(eventsByCategory: [String: [Event]]) -> [Section] {
        var sections = [Section]()
        for (categoryName, sectionEvents) in eventsByCategory {
            sections.append(Section(categoryName: categoryName, events: sectionEvents))
        }
    
        return sections
    }
}

