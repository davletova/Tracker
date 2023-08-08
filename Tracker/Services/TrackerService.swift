//
//  TrackerService.swift
//  Tracker
//
//  Created by Алия Давлетова on 05.08.2023.
//

import Foundation

protocol TrackerServiceProtocol {
    func getEventsByDate(date: Date) -> [Section]
}

protocol TrackerRecordServiceProtocol {
    func getRecordsByDate(date: Date) -> [TrackerRecord]
}

struct Section {
    let categoryName: String
    let events: [EventProtocol]
}

final class TrackerService {
    var events = [UUID: EventProtocol]()
    
    var trackerRecordService: TrackerRecordServiceProtocol
    
    init(trackerRecordService: TrackerRecordServiceProtocol) {
        self.trackerRecordService = trackerRecordService
        
        events = createMockEvents()
    }

    func getEventsByDate(date: Date) -> [Section] {
        guard let endOfDay = date.getEndOfDay() else {
            return [Section]()
        }
        
        if date < endOfDay {
            return getFutureEventsByDate(date: date)
        } else {
            return getPastEventsByDate(date: date)
        }
    }
    
    func getPastEventsByDate(date: Date) -> [Section] {
        print("getPastEventsByDate")
        var sections = [String: [EventProtocol]]()
        var eventIds = Set<UUID>()
        
        for record in trackerRecordService.getRecordsByDate(date: date) {
            eventIds.insert(record.eventID)
        }
        
        for eventId in eventIds {
            guard let event = events[eventId] else {
                continue
            }
            sections[event.getCategory().name]?.append(event)
        }
        
        return convertDictionaryToArray(dictionary: sections)
    }
    
    func getFutureEventsByDate(date: Date) -> [Section] {
        print("getFutureEventsByDate")
        guard let dayOfWeek = date.dayNumberOfWeek() else {
            print("failed to get weekday from \(date)")
            return [Section]()
        }
        
        var eventsCollection = [String: [EventProtocol]]()
        
        for (_, event) in events {
            if let schedule = event.getSchedule(),
               !schedule.repetition.contains(dayOfWeek) {
                continue
            }
               
            guard var sectionEvents = eventsCollection[event.getCategory().name] else {
                eventsCollection.updateValue([event], forKey: event.getCategory().name)
                continue
            }
            
            sectionEvents.append(event)
            eventsCollection.updateValue(sectionEvents, forKey: event.getCategory().name)
        }
        
        return convertDictionaryToArray(dictionary: eventsCollection)
    }
    
    func convertDictionaryToArray(dictionary: [String: [EventProtocol]]) -> [Section] {
        var sections = [Section]()
        
        for key in dictionary  {
            let section = Section(categoryName: key.key, events: key.value)
            sections.append(section)
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
