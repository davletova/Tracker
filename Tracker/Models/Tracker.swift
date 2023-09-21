//
//  Event.swift
//  Tracker
//
//  Created by Алия Давлетова on 01.08.2023.
//

import Foundation
import UIKit

class Tracker {
    var id: UUID
    var name: String
    var category: TrackerCategory
    var emoji: String
    var color: UIColor
    var pinned: Bool
    
    init(
        id: UUID,
        name: String,
        category: TrackerCategory,
        emoji: String,
        color: UIColor,
        pinned: Bool
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.emoji = emoji
        self.color = color
        self.pinned = pinned
    }
}
