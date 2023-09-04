//
//  TrackerCategoriesStoreProtocol.swift
//  Tracker
//
//  Created by Алия Давлетова on 02.09.2023.
//

import Foundation

protocol TrackerCategoryStoreProtocol {
    func getCategories() throws -> [TrackerCategoryCoreData]
    func addNewCategory(_ category: TrackerCategory) throws
    func deleteCategory(_ id: UUID) throws
}
