//
//  protocol.swift
//  Tracker
//
//  Created by Алия Давлетова on 21.09.2023.
//

import Foundation

protocol TrackerModifierProtocol {
    func makeSchedule(_ makeFunc: (TrackerScheduleCoreData) throws -> Void) throws -> TrackerScheduleCoreData
    func createTracker(_ createFunc: (TrackerCoreData) throws -> Void) throws -> TrackerCoreData
    func updateTracker(by id: UUID, _ updateFunc: (TrackerCoreData) throws -> Void) throws
}
