//
//  TrackerStoreProtocol.swift
//  Tracker
//
//  Created by Алия Давлетова on 28.08.2023.
//

import Foundation

protocol TrackerStoreProtocol: AnyObject {
//    func getTrackers(by date: Date, withName name: String?) -> [TrackersByCategory]
    func listTrackers(withFilter:  NSPredicate?, withSort: [NSSortDescriptor]) throws -> [TrackerCoreData]
    
    func addNewTracker(_ tracker: Tracker) throws
    func updateTracker(by id: UUID, _ updateFunc: (TrackerCoreData) throws -> Void) throws
    func deleteTracker(by id: UUID) throws
}
