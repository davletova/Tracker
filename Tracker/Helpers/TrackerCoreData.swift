//
//  TrackerCoreData.swift
//  Tracker
//
//  Created by Алия Давлетова on 20.09.2023.
//

import Foundation

extension TrackerCoreData {
    func toTracker() throws -> Tracker {
        guard let trackerID = self.trackerID else {
            throw TrackerStoreError.decodingErrorInvalidId
        }
        guard let trackerName = self.name else {
            throw TrackerStoreError.decodingErrorInvalidName
        }
        guard let trackerEmoji = self.emoji else {
            throw TrackerStoreError.decodingErrorInvalidEmojies
        }
        guard let trackerColorHex = self.colorHex else {
            throw TrackerStoreError.decodingErrorInvalidColorHex
        }
        guard
            let categoryCoreData = self.category,
            let categoryID = categoryCoreData.categoryID,
            let categoryName = categoryCoreData.name
        else {
            throw TrackerStoreError.decodingErrorInvalidCategory
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
