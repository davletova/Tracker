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
let category4 = Category(id: UUID.init(), name: "category4")
let category5 = Category(id: UUID.init(), name: "category5")
let category6 = Category(id: UUID.init(), name: "category6")
let category7 = Category(id: UUID.init(), name: "category7")
let category8 = Category(id: UUID.init(), name: "category8")
let category9 = Category(id: UUID.init(), name: "category9")
let category10 = Category(id: UUID.init(), name: "categor10")
let category11 = Category(id: UUID.init(), name: "category11")
let category12 = Category(id: UUID.init(), name: "category12")

//let mockCategories = [category1, category2, category3, category4, category5, category6, category7, category8, category10, category11, category12]
let mockCategories = [category1, category2, category3]

let habit1 = Habit(id: UUID.init(), name: "habit 1", category: category1, emoji: "❤️", color: color1, schedule: schedule)

let habit2 = Habit(id: UUID.init(), name: "habit 2", category: category2, emoji: "😡", color: color2, schedule: schedule)
let event1 = Tracker(id: UUID.init(), name: "event 1", category: category2, emoji: "🍋", color: color3)
let event2 = Tracker(id: UUID.init(), name: "event 2", category: category3, emoji: "🍊", color: color4)
let event3 = Tracker(id: UUID.init(), name: "здесь очень длинное название", category: category1, emoji: "🍈", color: color5)
let habit3 = Habit(id: UUID.init(), name: "habit 3", category: category2, emoji: "😡", color: color6, schedule: schedule)

func createMockEvents() -> [UUID: Tracker] {
    var mockEvents = [UUID: Tracker]()
    mockEvents[habit1.id] = habit1
    mockEvents[habit2.id] = habit2
    mockEvents[event1.id] = event1
    mockEvents[event2.id] = event2
    mockEvents[event3.id] = event3
    mockEvents[habit3.id] = habit3
    
    return mockEvents
//    return [UUID: Event]()
}

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


