//
//  Schedule.swift
//  Tracker
//
//  Created by Алия Давлетова on 01.08.2023.
//

import Foundation

enum Weekday: Int, CaseIterable {
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7
    case sunday = 1
}

struct Schedule {
    var startDate: Date
    var repetition: Set<Weekday>
    
    init(startDate: Date, repetition: Set<Weekday>) {
        self.startDate = startDate
        self.repetition = repetition
    }
}
