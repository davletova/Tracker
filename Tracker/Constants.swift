//
//  Constants.swift
//  Tracker
//
//  Created by Алия Давлетова on 25.08.2023.
//

import Foundation
import UIKit

enum AppColor {
    case backgroundDay, backgroundNight, blackDay, blackNight, blue, gray
    case lightGray, red, whiteDay, whiteNight, tabBarBorder
    
    func getColor() -> UIColor {
        switch self {
        case .backgroundDay:
            guard let backgroundDay = UIColor(named: "BackgroundDay") else {
                assertionFailure("backgroundDayColor not found")
                return .gray
            }
            return backgroundDay
        case .backgroundNight:
            guard let backgroundNight = UIColor(named: "BackgroundNight") else {
                assertionFailure("BackgroundNight color not found")
                return UIColor.gray
            }
            return backgroundNight
        case .blackDay:
            guard let blackDay = UIColor(named: "BlackDay") else {
                assertionFailure("BlackDay color not found")
                return UIColor.gray
            }
            return blackDay
        case .blackNight:
            guard let blackNight = UIColor(named: "BlackNight") else {
                assertionFailure("BlackNight color not found")
                return UIColor.white
            }
            return blackNight
        case .blue:
            guard let blue = UIColor(named: "Blue") else {
                assertionFailure("blueColor not found")
                return UIColor.blue
            }
            return blue
        case .gray:
            guard let gray = UIColor(named: "Gray") else {
                assertionFailure("Gray not found")
                return UIColor.gray
            }
            return gray
        case .lightGray:
            guard let lightGray = UIColor(named: "LightGray") else {
                assertionFailure("lightGray not found")
                return UIColor.lightGray
            }
            return lightGray
        case .red:
            guard let red = UIColor(named: "Red") else {
                assertionFailure("Red not found")
                return UIColor.red
            }
            return red
        case .whiteDay:
            guard let whiteDay = UIColor(named: "WhiteDay") else {
                assertionFailure("whiteDay not found")
                return UIColor.red
            }
            return whiteDay
        case .whiteNight:
            guard let whiteNight = UIColor(named: "WhiteNight") else {
                assertionFailure("WhiteNight not found")
                return UIColor.red
            }
            return whiteNight
        case .tabBarBorder:
            guard let tabBarBorder = UIColor(named: "TabBarBorder") else {
                assertionFailure("TabBarBorder not found")
                return UIColor.lightGray
            }
            return tabBarBorder
            
        }
    }
}

let rowHeight: CGFloat = 75
let buttonHeight: CGFloat = 60
