//
//  CreateEventViewModel.swift
//  Tracker
//
//  Created by Алия Давлетова on 20.09.2023.
//

import Foundation
protocol CreateEventViewModelProtocol {
    func updateTracker(_ tracker: Tracker) throws
    func createTracker(_ tracker: Tracker) throws
}

protocol GetCategoryProtocol {
    func getCategory(by id: UUID) throws -> TrackerCategoryCoreData
}

protocol TrackerModifierProtocol {
    func makeSchedule(_ makeFunc: (TrackerScheduleCoreData) throws -> Void) throws -> TrackerScheduleCoreData
    func createTracker(_ createFunc: (TrackerCoreData) throws -> Void) throws -> TrackerCoreData
    func updateTracker(by id: UUID, _ updateFunc: (TrackerCoreData) throws -> Void) throws
}

final class CreateEventViewModel: CreateEventViewModelProtocol {
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
            
            if tracker.category.id == trackerCoreData.category!.categoryID {
                return
            }
            
            let category = try categoryStore.getCategory(by: tracker.category.id)
            trackerCoreData.category = category
            
            if let habit = tracker as? Timetable {
                guard let _ = trackerCoreData.schedule else {
                    assertionFailure("should never be happen")
                    return
                }
                        
                for weekDay in habit.getSchedule().repetition {
                    switch weekDay {
                    case .monday:
                        trackerCoreData.schedule!.monday = true
                    case .tuesday:
                        trackerCoreData.schedule!.tuesday = true
                    case .wednesday:
                        trackerCoreData.schedule!.wednesday = true
                    case .thursday:
                        trackerCoreData.schedule!.thursday = true
                    case .friday:
                        trackerCoreData.schedule!.friday = true
                    case .saturday:
                        trackerCoreData.schedule!.saturday = true
                    case .sunday:
                        trackerCoreData.schedule!.sunday = true
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
