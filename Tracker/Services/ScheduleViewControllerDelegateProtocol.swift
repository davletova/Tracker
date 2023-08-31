//
//  ScheduleViewControllerDelegateProtocol.swift
//  Tracker
//
//  Created by Алия Давлетова on 23.08.2023.
//

import Foundation

protocol ScheduleViewControllerDelegateProtocol: AnyObject {
    func saveSchedule(schedule: Schedule)
}
