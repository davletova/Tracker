//
//  TrackerStoreProtocol.swift
//  Tracker
//
//  Created by Алия Давлетова on 28.08.2023.
//

import Foundation

protocol TrackerStoreProtocol: AnyObject {
    func getTrackers(by date: Date, withName name: String?) -> [TrackersByCategory]

    func addNewTracker(_ tracker: Tracker) throws
    func updateTracker(_ tracker: Tracker) throws
    func deleteTracker(_ tracker: Tracker) throws
}
