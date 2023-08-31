//
//  Color.swift
//  Tracker
//
//  Created by Алия Давлетова on 29.08.2023.
//

import Foundation
import UIKit

extension UIColor {
    static func getAppColors(_ colorName: AppColor) -> UIColor {
        colorName.getColor()
    }
}
