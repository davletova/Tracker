//
//  Event.swift
//  Tracker
//
//  Created by Алия Давлетова on 01.08.2023.
//

import Foundation
import UIKit

class Tracker {
    let id: UUID
    let name: String
    let category: Category
    let emoji: String
    let color: UIColor
    
    init(
        id: UUID,
        name: String,
        category: Category,
        emoji: String,
        color: UIColor
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.emoji = emoji
        self.color = color
    }
}