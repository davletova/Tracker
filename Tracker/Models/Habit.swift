//
//  Habit.swift
//  Tracker
//
//  Created by Алия Давлетова on 01.08.2023.
//

import Foundation
import UIKit
import CoreData

protocol Timetable {
    func getSchedule() -> Schedule
}

final class Habit: Tracker {
    var schedule: Schedule
    
    init(
        name: String,
        category: TrackerCategory,
        emoji: String,
        color: UIColor,
        schedule: Schedule
    ) {
        self.schedule = schedule
        super.init(name: name, category: category, emoji: emoji, color: color)
    }
}

extension Habit: Timetable {
    func getSchedule() -> Schedule { schedule }
}
