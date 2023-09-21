//
//  protocol.swift
//  Tracker
//
//  Created by Алия Давлетова on 21.09.2023.
//

import Foundation

protocol CreateTrackerViewModelProtocol {
    func updateTracker(_ tracker: Tracker) throws
    func createTracker(_ tracker: Tracker) throws
}
