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
    
    func getRepetitionString() -> String {
        var repetitionString = repetition
            .sorted(by: { weekday1, weekday2 in
                weekday1.rawValue < weekday2.rawValue
            })
            .map({ weekday in
            switch weekday {
            case .monday:
                return "Пн"
            case .tuesday:
                return "Вт"
            case .wednesday:
                 return "Ср"
            case .thursday:
                return "Чт"
            case .friday:
                return "Пт"
            case .saturday:
                return "Сб"
            case .sunday:
                return "Вс"
            }
        })
        
        return repetitionString.joined(separator: ", ")
    }
}
