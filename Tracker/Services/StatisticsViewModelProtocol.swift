//
//  protocol.swift
//  Tracker
//
//  Created by Алия Давлетова on 21.09.2023.
//

import Foundation

protocol StatisticsViewModelProtocol {
    func getTrackersCount() throws -> Int
    func getBestPeriod() throws -> Int
    func getCountOfIdealDays() throws -> Int
    func getTotalPerformedHabits() throws -> Int
    func getAverrage() throws -> Int
}
