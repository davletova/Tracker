//
//  Date.swift
//  Tracker
//
//  Created by Алия Давлетова on 01.08.2023.
//

import Foundation

extension Date {
    func dayNumberOfWeek() -> Weekday? {
        let calendar = Calendar(identifier: .iso8601)
        let numberOfDay = calendar.dateComponents([.weekday], from: self).weekday
        
        switch numberOfDay {
        case 1:
            return Weekday.sunday
        case 2:
            return Weekday.monday
        case 3:
            return Weekday.tuesday
        case 4:
            return Weekday.wednesday
        case 5:
            return Weekday.thursday
        case 6:
            return Weekday.friday
        case 7:
            return Weekday.saturday
        default:
            return nil
        }
    }
    
    func getBeginningOfDay() -> Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    func getEndOfDay() -> Date? {
        guard let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: self) else {
            print("failed to create next date from \(self)")
            return nil
        }
        return Calendar.current.startOfDay(for: nextDay)
    }
    
    func inDay(day: Date) -> Bool? {
        let begin = day.getBeginningOfDay()
        guard let end = day.getEndOfDay() else {
            return nil
        }
        
        return self >= begin || self < end
    }
}
