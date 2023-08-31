//
//  ListCategoriesDelegateProtocol.swift
//  Tracker
//
//  Created by Алия Давлетова on 23.08.2023.
//

import Foundation

protocol ListCategoriesDelegateProtocol: AnyObject {
    func saveCategory(category: TrackerCategory)
}
