//
//  TrackerScheduleCoreData.swift
//  Tracker
//
//  Created by Алия Давлетова on 20.09.2023.
//

import Foundation

extension TrackerScheduleCoreData {
    func toSchedule() -> Schedule {
        var repetition = Set<Weekday>()
        
        if self.monday {
            repetition.insert(Weekday.monday)
        }
        if self.tuesday {
            repetition.insert(Weekday.tuesday)
        }
        if self.wednesday {
            repetition.insert(Weekday.wednesday)
        }
        if self.thursday {
            repetition.insert(Weekday.thursday)
        }
        if self.friday {
            repetition.insert(Weekday.friday)
        }
        if self.saturday {
            repetition.insert(Weekday.saturday)
        }
        if self.sunday {
            repetition.insert(Weekday.sunday)
        }
        
        return Schedule(startDate: Date(), repetition: repetition)
    }
}
