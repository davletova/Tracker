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
        tracker: Tracker,
        schedule: Schedule
    ) {
        self.schedule = schedule
        super.init(
            id: tracker.id,
            name: tracker.name,
            category: tracker.category,
            emoji: tracker.emoji,
            color: tracker.color
        )
    }
}

extension Habit: Timetable {
    func getSchedule() -> Schedule { schedule }
}
