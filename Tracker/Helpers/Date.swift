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
}
