//
//  Event.swift
//  Tracker
//
//  Created by Алия Давлетова on 01.08.2023.
//

import Foundation
import UIKit

class Event {
    let id: UUID
    var name: String
    var category: Category
    var trackedDaysCount: Int
    var emoji: String
    var color: UIColor
    
    init(id: UUID, name: String, category: Category, emoji: String, color: UIColor) {
        self.id = id
        self.name = name
        self.category = category
        self.trackedDaysCount = 0
        self.emoji = emoji
        self.color = color
    }
}
