//
//  CreateEventViewModel.swift
//  Tracker
//
//  Created by Алия Давлетова on 20.09.2023.
//

import Foundation

protocol GetCategoryProtocol {
    func getCategory(by id: UUID) throws -> TrackerCategoryCoreData
}

final class CreateTrackerViewModel: CreateTrackerViewModelProtocol {
    let categoryStore: GetCategoryProtocol
    let trackerStore: TrackerModifierProtocol
    
    init(categoryStore: GetCategoryProtocol, trackerStore: TrackerModifierProtocol) {
        self.categoryStore = categoryStore
        self.trackerStore = trackerStore
    }
    
    func updateTracker(_ tracker: Tracker) throws {
        try trackerStore.updateTracker(by: tracker.id) { trackerCoreData in
            trackerCoreData.name = tracker.name
            trackerCoreData.emoji = tracker.emoji
            trackerCoreData.colorHex = UIColorMarshalling.hexString(from: tracker.color)
            trackerCoreData.pinned = tracker.pinned
            
            if let category = trackerCoreData.category,
               tracker.category.id != category.categoryID
            {
                trackerCoreData.category = try categoryStore.getCategory(by: tracker.category.id)
            }
            
            if let habit = tracker as? Timetable {

                guard let schedule = trackerCoreData.schedule else {
                    assertionFailure("failed to get schedule from trackerCoreData")
                    return
                }
                        
                for weekDay in Weekday.allCases {
                    switch weekDay {
                    case .monday:
                        schedule.monday = habit.getSchedule().repetition.contains(.monday)
                    case .tuesday:
                        schedule.tuesday = habit.getSchedule().repetition.contains(.tuesday)
                    case .wednesday:
                        schedule.wednesday = habit.getSchedule().repetition.contains(.wednesday)
                    case .thursday:
                        schedule.thursday = habit.getSchedule().repetition.contains(.thursday)
                    case .friday:
                        schedule.friday = habit.getSchedule().repetition.contains(.friday)
                    case .saturday:
                        schedule.saturday = habit.getSchedule().repetition.contains(.saturday)
                    case .sunday:
                        schedule.sunday = habit.getSchedule().repetition.contains(.sunday)
                    }
                }
            }
        }
    }
    
    func createTracker(_ tracker: Tracker) throws {
        var trackerSchedule: TrackerScheduleCoreData?
        if let habit = tracker as? Timetable {
            trackerSchedule = try trackerStore.makeSchedule { trackerSchedule in
                for weekDay in habit.getSchedule().repetition {
                    switch weekDay {
                    case .monday:
                        trackerSchedule.monday = true
                    case .tuesday:
                        trackerSchedule.tuesday = true
                    case .wednesday:
                        trackerSchedule.wednesday = true
                    case .thursday:
                        trackerSchedule.thursday = true
                    case .friday:
                        trackerSchedule.friday = true
                    case .saturday:
                        trackerSchedule.saturday = true
                    case .sunday:
                        trackerSchedule.sunday = true
                    }
                }
            }
        }
        
        let category = try categoryStore.getCategory(by: tracker.category.id)
        let _ = try trackerStore.createTracker { newTracker in
            newTracker.trackerID = tracker.id
            newTracker.name = tracker.name
            newTracker.category = category
            newTracker.createDate = Date()
            newTracker.emoji = tracker.emoji
            newTracker.colorHex = UIColorMarshalling.hexString(from: tracker.color)
            newTracker.pinned = tracker.pinned
            newTracker.schedule = trackerSchedule
        }
    }
}
