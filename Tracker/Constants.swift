//
//  Constants.swift
//  Tracker
//
//  Created by Алия Давлетова on 25.08.2023.
//

import Foundation
import UIKit

enum AppColor {
    case backgroundDay, backgroundNight, blackDay, blackNight, blue, gray, datePickerBackground, datePickerTitle
    case lightGray, red, whiteDay, whiteNight, tabBarBorder, gradient1, gradient2, gradient3
    
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
        case .gradient1:
            guard let gradient1 = UIColor(named: "Gradient1") else {
                assertionFailure("Gradient1 not found")
                return UIColor.red
            }
            return gradient1
        case .gradient2:
            guard let gradient2 = UIColor(named: "Gradient2") else {
                assertionFailure("Gradient2 not found")
                return UIColor.green
            }
            return gradient2
        case .gradient3:
            guard let gradient3 = UIColor(named: "Gradient3") else {
                assertionFailure("Gradient3 not found")
                return UIColor.blue
            }
            return gradient3
        case .datePickerBackground:
            guard let datePickerBackground = UIColor(named: "DatePickerBackground") else {
                assertionFailure("datePickerBackground not found")
                return UIColor.lightGray
            }
            return datePickerBackground
        case .datePickerTitle:
            guard let datePickerTitle = UIColor(named: "DatePickerTitle") else {
                assertionFailure("datePickerdatePickerTitleBackground not found")
                return UIColor.black
            }
            return datePickerTitle
        }
    }
}

let rowHeight: CGFloat = 75
let buttonHeight: CGFloat = 60

let isOnbordingShown = "isOnbordingShown"
