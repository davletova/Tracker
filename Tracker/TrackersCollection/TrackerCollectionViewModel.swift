//
//  TrackerCollectionViewModel.swift
//  Tracker
//
//  Created by Алия Давлетова on 19.09.2023.
//

import Foundation

protocol TrackerCollectionViewModelProtocol {
    func deleteTracker(_ tracker: Tracker) throws
    func togglePinnedTracker(_ tracker: Tracker) throws
    func listTrackers(for date: Date, withName name: String, withFilter filter: TrackerFilterType) throws -> [TrackersByCategory]
}

class TrackerCollectionViewModel: TrackerCollectionViewModelProtocol {
    private let trackerStore: TrackerStoreProtocol
    private let trackerCategoryStore: TrackerCategoryStore = TrackerCategoryStore()
    
    init(trackerStore: TrackerStoreProtocol) {
        self.trackerStore = trackerStore
    }
    
    func deleteTracker(_ tracker: Tracker) throws {
        try trackerStore.deleteTracker(by: tracker.id)
    }
    
    func togglePinnedTracker(_ tracker: Tracker) throws {
        try trackerStore.updateTracker(by: tracker.id) { trackerCoreData in
            trackerCoreData.pinned = tracker.pinned
        }
    }
    
    func listTrackers(for date: Date, withName name: String, withFilter filter: TrackerFilterType) throws -> [TrackersByCategory] {
        let dayOfWeek = String(describing: date.dayNumberOfWeek())
        
        var predicate = NSCompoundPredicate.init(type: .or, subpredicates: [
            NSCompoundPredicate.init(type: .and, subpredicates: [
                NSPredicate(format: "%K != nil", #keyPath(TrackerCoreData.schedule)),
                NSPredicate(format: "%K.\(dayOfWeek) = true", #keyPath(TrackerCoreData.schedule)),
            ]),
            NSPredicate(format: "%K == nil", #keyPath(TrackerCoreData.schedule))
        ])
        
        if !name.isEmpty {
            predicate = NSCompoundPredicate.init(type: .and, subpredicates: [
                predicate,
                NSPredicate(format: "%K CONTAINS[cd] %@", #keyPath(TrackerCoreData.name), name)
            ])
        }
        
        switch filter {
        case .unfinished:
            predicate = NSCompoundPredicate.init(type: .and, subpredicates: [
                predicate,
                NSPredicate(format: "%K != nil", #keyPath(TrackerCoreData.schedule)),
                NSPredicate(format: "records.@count == 0 OR (NOT ANY records.date == %@)", Calendar.current.startOfDay(for: date) as NSDate)
            ])
        case .finished:
            predicate = NSCompoundPredicate.init(type: .and, subpredicates: [
                predicate,
                NSPredicate(format: "%K != nil", #keyPath(TrackerCoreData.schedule)),
                NSPredicate(format: "(ANY records.date == %@)", Calendar.current.startOfDay(for: date) as NSDate)
            ])
        case .today:
            predicate = NSCompoundPredicate.init(type: .and, subpredicates: [
                predicate,
                NSPredicate(format: "(ANY records.date == %@)", Calendar.current.startOfDay(for: Date()) as NSDate)
            ])
        case .all:
            // ничего не делаем и так по умолчанию все должны выбираться
            break
        }
        
        let trackers = try trackerStore.listTrackers(withFilter: predicate, withSort: [])
        let trackersByCategory = Dictionary(grouping: trackers) { (tracker) -> String in
            guard
                let category = tracker.category,
                let categoryName = tracker.pinned ?
                    NSLocalizedString("main.section.pinned.title", comment: "Секция закрепленных трекеров") : category.name
            else {
                assertionFailure("failed to get category name of tarcker \(tracker.id)")
                return ""
            }
            
            return categoryName
        }
        
        return try trackersByCategory.map { (categoryName: String, trackersCoreData: [TrackerCoreData]) in
            var trackerViewModels = [TrackerViewModel]()
            for trackerCoreData in trackersCoreData {
                let tracker = try trackerCoreData.toTracker()
                guard let records = trackerCoreData.records, records.count > 0 else {
                    trackerViewModels.append(TrackerViewModel(event: tracker, trackedDaysCount: 0, tracked: false))
                    continue
                }
                
                let record = records.first { record in
                    guard let trackerRecordCoreData = record as? TrackerRecordCoreData else {
                        assertionFailure("failed to convert tarckerRecordCoreData")
                        return false
                    }
                    
                    return trackerRecordCoreData.date == Calendar.current.startOfDay(for: date)
                }
                
                trackerViewModels.append(TrackerViewModel(event: tracker, trackedDaysCount: records.count, tracked: record != nil))
            }
            
            return TrackersByCategory(categoryName: categoryName, trackers: trackerViewModels)
        }.sorted { cat1, cat2 in
            if cat1.categoryName == NSLocalizedString("main.section.pinned.title", comment: "") {
                return true
            }
            
            if cat2.categoryName == NSLocalizedString("main.section.pinned.title", comment: "") {
                return false
            }
            
            return cat1.categoryName < cat2.categoryName
        }
    }
    
}
