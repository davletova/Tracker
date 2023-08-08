//
//  Event.swift
//  Tracker
//
//  Created by Алия Давлетова on 01.08.2023.
//

import Foundation
import UIKit

class Event: EventProtocol {
    let id: UUID
    var name: String
    var category: Category
    var emoji: String
    var color: UIColor
    
    init(id: UUID, name: String, category: Category, emoji: String, color: UIColor) {
        self.id = id
        self.name = name
        self.category = category
        self.emoji = emoji
        self.color = color
    }
    
    func getID() -> UUID { return id }
    
    func getName() -> String { return name }
    
    func getEmoji() -> String { return emoji }
    
    func getSchedule() -> Schedule? { return nil }
    
    func getCategory() -> Category { return category }
    
    func getColor() -> UIColor { return color }
}
