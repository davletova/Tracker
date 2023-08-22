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
}

struct TrackerCategory {
    var categoryName: String
    var trackers: [Tracker]
}

final class TrackerService {
    var categories = [TrackerCategory]()
    
    init() {
        categories = mockEvents
    }
}

extension TrackerService: TrackerServiceProtocol {
    func getTrackers(by date: Date) -> [TrackerCategory] {
        var eventsByDate = categories
        
        guard let dayOfWeek = date.dayNumberOfWeek() else {
            print("failed to get day of week")
            return [TrackerCategory]()
        }
        
        for i in (0..<eventsByDate.count).reversed() {
            for j in (0..<eventsByDate[i].trackers.count).reversed() {
                if let habit = eventsByDate[i].trackers[j] as? Timetable {
                    if !habit.getSchedule().repetition.contains(dayOfWeek) {
                        eventsByDate[i].trackers.remove(at: j)
                    }
                }
            }
            
            if eventsByDate[i].trackers.isEmpty {
                eventsByDate.remove(at: i)
            }
        }
        
        return eventsByDate
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
        for i in (0..<categories.count) {
            if categories[i].categoryName == tracker.name {
                categories[i].trackers.append(tracker)
                return
            }
        }
        
        categories.append(TrackerCategory(categoryName: tracker.name, trackers: [tracker]))
        
        NotificationCenter.default.post(
            name: TrackerCollectionView.TrackerSavedNotification,
            object: self,
            userInfo: ["event": tracker]
        )
    }
    
//    func updateTracker(tracker updateEvent: Tracker) -> Tracker? {
//        events.updateValue(updateEvent, forKey: updateEvent.id)
//
//        return events[updateEvent.id]
//    }
    
//    func deleteTracker(trackerID: UUID) {
//        events.removeValue(forKey: trackerID)
//    }
//
//    private func putTrackersToSections(eventsByCategory: [String: [Tracker]]) -> [TrackerCategory] {
//        var sections = [TrackerCategory]()
//        for (categoryName, sectionEvents) in eventsByCategory {
//            sections.append(TrackerCategory(categoryName: categoryName, trackers: sectionEvents))
//        }
//
//        return sections
//    }
}

