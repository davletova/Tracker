//
//  Habit.swift
//  Tracker
//
//  Created by Алия Давлетова on 01.08.2023.
//

import Foundation
import UIKit

protocol Timetable {
    func getSchedule() -> Schedule
}

final class Habit: Event, Timetable {
    var schedule: Schedule

    init(id: UUID, name: String, category: Category, emoji: String, color: UIColor, schedule: Schedule) {
        self.schedule = schedule
        super.init(id: id, name: name, category: category, emoji: emoji, color: color)
    }
    
    func getSchedule() -> Schedule { schedule }
}
