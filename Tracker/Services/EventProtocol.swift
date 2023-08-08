//
//  HabitProtocol.swift
//  Tracker
//
//  Created by Алия Давлетова on 01.08.2023.
//

import Foundation
import UIKit

protocol EventProtocol {
    func getID() -> UUID
    
    func getName() -> String
    
    func getEmoji() -> String
    
    func getSchedule() -> Schedule?
    
    func getCategory() -> Category
    
    func getColor() -> UIColor
}
