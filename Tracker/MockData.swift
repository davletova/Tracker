//
//  MockData.swift
//  Tracker
//
//  Created by Алия Давлетова on 05.08.2023.
//

import Foundation
import UIKit

let color1 = UIColor(named: "ColorSelection1") ?? .red
let color2 = UIColor(named: "ColorSelection2") ?? .red
let color3 = UIColor(named: "ColorSelection3") ?? .red
let color4 = UIColor(named: "ColorSelection4") ?? .red
let color5 = UIColor(named: "ColorSelection5") ?? .red
let color6 = UIColor(named: "ColorSelection6") ?? .red

let schedule = Schedule(startDate: Date(), repetition: [Weekday.friday, Weekday.monday])
let category1 = Category(id: UUID.init(), name: "category1")
let category2 = Category(id: UUID.init(), name: "category2")
let category3 = Category(id: UUID.init(), name: "category3")

let mockCategories = [category1, category2, category3]

let habit1 = Habit(id: UUID.init(), name: "habit 1", category: category1, emoji: "❤️", color: color1, schedule: schedule)
let habit2 = Habit(id: UUID.init(), name: "habit 2", category: category2, emoji: "😡", color: color2, schedule: schedule)
let event1 = Event(id: UUID.init(), name: "event 1", category: category2, emoji: "🍋", color: color3)
let event2 = Event(id: UUID.init(), name: "event 2", category: category3, emoji: "🍊", color: color4)
let event3 = Event(id: UUID.init(), name: "event 3", category: category1, emoji: "🍈", color: color5)
let habit3 = Habit(id: UUID.init(), name: "habit 3", category: category2, emoji: "😡", color: color6, schedule: schedule)

func createMockEvents() -> [UUID: EventProtocol] {
    var mockEvents = [UUID: EventProtocol]()
    
    mockEvents[habit1.getID()] = habit1
    mockEvents[habit2.getID()] = habit2
    mockEvents[event1.getID()] = event1
    mockEvents[event2.getID()] = event2
    mockEvents[event3.getID()] = event3
    mockEvents[habit3.getID()] = habit3
    
    return mockEvents
}

let s1 = Section(categoryName: category1.name, events: [habit1, event1, event3])
let s2 = Section(categoryName: category2.name, events: [habit2])
let s3 = Section(categoryName: category3.name, events: [event2])

let mockTrackerRecords: [TrackerRecord] = [
    TrackerRecord(eventID: habit2.id, date: dateFromString(date: "2023-08-04T10:44:00")),
    TrackerRecord(eventID: habit1.id, date: dateFromString(date: "2023-08-05T10:44:00")),
    TrackerRecord(eventID: event1.id, date: dateFromString(date: "2023-08-04T10:44:00")),
    TrackerRecord(eventID: event2.id, date: dateFromString(date: "2023-08-03T10:44:00")),
    TrackerRecord(eventID: event3.id, date: dateFromString(date: "2023-08-04T10:44:00"))
]

func dateFromString(date: String) -> Date {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    return dateFormatter.date(from: date)!
}   


