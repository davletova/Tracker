//
//  TrackerCoreData.swift
//  Tracker
//
//  Created by Алия Давлетова on 20.09.2023.
//

import Foundation

enum TrackerCoreDataError: Error {
    case decodingErrorInvalidId
    case decodingErrorInvalidName
    case decodingErrorInvalidCategory
    case decodingErrorInvalidCategoryName
    case decodingErrorInvalidEmojies
    case decodingErrorInvalidColorHex
    case categoryNotFound
    case generateURLError
    case getTrackerError
}

extension TrackerCoreData {
    func toTracker() throws -> Tracker {
        guard let trackerID = self.trackerID else {
            throw TrackerCoreDataError.decodingErrorInvalidId
        }
        guard let trackerName = self.name else {
            throw TrackerCoreDataError.decodingErrorInvalidName
        }
        guard let trackerEmoji = self.emoji else {
            throw TrackerCoreDataError.decodingErrorInvalidEmojies
        }
        guard let trackerColorHex = self.colorHex else {
            throw TrackerCoreDataError.decodingErrorInvalidColorHex
        }
        guard
            let categoryCoreData = self.category,
            let categoryID = categoryCoreData.categoryID,
            let categoryName = categoryCoreData.name
        else {
            throw TrackerCoreDataError.decodingErrorInvalidCategory
        }
        
        let tracker = Tracker(
            id: trackerID,
            name: trackerName,
            category: TrackerCategory(id: categoryID, name: categoryName),
            emoji: trackerEmoji,
            color: UIColorMarshalling.color(from: trackerColorHex),
            pinned: self.pinned
        )
        
        if let schedule = self.schedule {
            let habit = Habit(tracker: tracker, schedule: schedule.toSchedule())
            
            return habit
        }
        
        return tracker
    }
}
