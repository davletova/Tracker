//
//  TrackerViewModel.swift
//  Tracker
//
//  Created by Алия Давлетова on 29.08.2023.
//

import Foundation

struct TrackerViewModel {
    var tracker: Tracker
    var tracked: Bool
    var trackedDaysCount: Int
    
    init(event: Tracker,
         trackedDaysCount: Int,
         tracked: Bool
    ) {
        self.tracker = event
        self.trackedDaysCount = trackedDaysCount
        self.tracked = tracked
    }
}
