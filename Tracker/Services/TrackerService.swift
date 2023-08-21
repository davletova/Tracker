//
//  TrackerService.swift
//  Tracker
//
//  Created by Алия Давлетова on 05.08.2023.
//

import Foundation

protocol TrackerServiceProtocol {
    func getTrackers(by date: Date) -> [TrackerCategory]
    func filterTrackers(by name: String, date: Date) -> [TrackerCategory]
    func createTracker(tracker: Tracker)
    func updateTracker(tracker: Tracker) -> Tracker?
    func deleteTracker(trackerID: UUID)
}

final class TrackerService {
    static let CreateTrackerNotification = Notification.Name(rawValue: "creatEvent")
    
    var events = [UUID: Tracker]()
    
    init() {
        events = createMockEvents()
        
        NotificationCenter.default.addObserver(
            forName: TrackerService.CreateTrackerNotification,
            object: nil,
            queue: OperationQueue.main
        ) { [weak self] notification in
            guard let self = self else {
                print("TrackerService, CreateEventNotification: self is empty")
                return
            }
            
            guard let event = notification.userInfo?["event"] as? Tracker else {
                print("failed to convert event: \(String(describing: notification.userInfo?["event"]))")
                return
            }
            
            self.createTracker(tracker: event)
        }
    }
}

extension TrackerService: TrackerServiceProtocol {
    func getTrackers(by date: Date) -> [TrackerCategory] {
        var eventsByCategory = [String: [Tracker]]()
        
        guard let dayOfWeek = date.dayNumberOfWeek() else {
            print("failed to get day of week")
            return [TrackerCategory]()
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
        
        return putTrackersToSections(eventsByCategory: eventsByCategory)
    }
    
    func filterTrackers(by name: String, date: Date) -> [TrackerCategory] {
        var eventsByDate = getTrackers(by: date)
        
        for i in (0..<eventsByDate.count).reversed() {
            eventsByDate[i].trackers = eventsByDate[i].trackers.filter({ $0.name.lowercased().contains(name.lowercased()) })
            
            if eventsByDate[i].trackers.isEmpty {
                eventsByDate.remove(at: i)
            }
        }
        
        return eventsByDate
    }
    
    func createTracker(tracker: Tracker) {
        events.updateValue(tracker, forKey: tracker.id)
        
        NotificationCenter.default.post(
            name: TrackerCollectionView.TrackerSavedNotification,
            object: self,
            userInfo: ["event": tracker]
        )
    }
    
    func updateTracker(tracker updateEvent: Tracker) -> Tracker? {
        events.updateValue(updateEvent, forKey: updateEvent.id)
    
        return events[updateEvent.id]
    }
    
    func deleteTracker(trackerID: UUID) {
        events.removeValue(forKey: trackerID)
    }
    
    private func putTrackersToSections(eventsByCategory: [String: [Tracker]]) -> [TrackerCategory] {
        var sections = [TrackerCategory]()
        for (categoryName, sectionEvents) in eventsByCategory {
            sections.append(TrackerCategory(categoryName: categoryName, trackers: sectionEvents))
        }
    
        return sections
    }
}

