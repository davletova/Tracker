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

let schedule = Schedule(startDate: Date(), repetition: [Weekday.sunday, Weekday.monday])

let habit1 = Habit(id: UUID.init(), name: "habit 1", category: "category1", emoji: "❤️", color: color1, schedule: schedule)
let habit2 = Habit(id: UUID.init(), name: "habit 2", category: "category2", emoji: "😡", color: color2, schedule: schedule)
let event1 = Tracker(id: UUID.init(), name: "event 1", category: habit1.category, emoji: "🍋", color: color3)
let event2 = Tracker(id: UUID.init(), name: "event 2", category: habit2.category, emoji: "🍊", color: color4)
let event3 = Tracker(id: UUID.init(), name: "здесь очень длинное название", category: habit2.category, emoji: "🍈", color: color5)
let habit3 = Habit(id: UUID.init(), name: "habit 3", category: "category3", emoji: "😡", color: color6, schedule: schedule)

let category1 = TrackerCategory(categoryName: habit1.category, trackers: [habit1, event1])
let category2 = TrackerCategory(categoryName: habit2.category, trackers: [habit2, event2, event3])
let category3 = TrackerCategory(categoryName: habit3.category, trackers: [habit3])

let mockEvents = [category1, category2, category3]

let mockTrackerRecords: [TrackerRecord] = [
    TrackerRecord(eventID: habit2.id, date: Calendar.current.startOfDay(for: dateFromString(date: "2023-08-04T10:44:00"))),
    TrackerRecord(eventID: habit1.id, date: Calendar.current.startOfDay(for: dateFromString(date: "2023-08-05T10:44:00"))),
    TrackerRecord(eventID: event1.id, date: Calendar.current.startOfDay(for: dateFromString(date: "2023-08-04T10:44:00"))),
    TrackerRecord(eventID: event2.id, date: Calendar.current.startOfDay(for: dateFromString(date: "2023-08-03T10:44:00"))),
    TrackerRecord(eventID: event3.id, date: Calendar.current.startOfDay(for: dateFromString(date: "2023-08-04T10:44:00"))),
    TrackerRecord(eventID: habit1.id, date: Calendar.current.startOfDay(for: dateFromString(date: "2023-08-14T10:44:00")))
]

//let mockTrackerRecords = [TrackerRecord]()

func dateFromString(date: String) -> Date {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    return dateFormatter.date(from: date)!
}   


