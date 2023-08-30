//
//  TrackerActionProtocol.swift
//  Tracker
//
//  Created by Алия Давлетова on 30.08.2023.
//

import Foundation

protocol TrackerActionProtocol: AnyObject {
    func cancelCreateEvent()
    func createEvent()
}
