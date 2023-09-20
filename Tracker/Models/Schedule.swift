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
    
    var localizeLabel: String {
        switch self {
        case .monday:
            return NSLocalizedString("schedule.monday", comment: "поле Понедельник в таблице с расписанием")
        case .tuesday:
            return NSLocalizedString("schedule.tuesday", comment: "поле Вторник в таблице с расписанием")
        case .wednesday:
            return NSLocalizedString("schedule.wednesday", comment: "поле Среда в таблице с расписанием")
        case .thursday:
            return NSLocalizedString("schedule.thursday", comment: "поле Четверг в таблице с расписанием")
        case .friday:
            return NSLocalizedString("schedule.friday", comment: "поле Пятница в таблице с расписанием")
        case .saturday:
            return NSLocalizedString("schedule.saturday", comment: "поле Суббота в таблице с расписанием")
        case .sunday:
            return NSLocalizedString("schedule.sunday", comment: "поле Воскресенье в таблице с расписанием")
        }
    }
}

struct Schedule {
    var startDate: Date
    var repetition: Set<Weekday>
    
    init(startDate: Date, repetition: Set<Weekday>) {
        self.startDate = startDate
        self.repetition = repetition
    }
    
    func getRepetitionString() -> String {
        let repetitionString = repetition
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
