//
//  CategoryService.swift
//  Tracker
//
//  Created by Алия Давлетова on 09.08.2023.
//

import Foundation

protocol CategoryServiceProtocol {
    func addCategory(category: Category)
    func updateCategory(category: Category)
    func deleteCategory(category: Category)
    func getCategories() -> [Category]
}

final class CategoryService: CategoryServiceProtocol {
    private var listOfCategories: [Category]
    
    init() {
        listOfCategories = [
            Category(id: UUID(), name: "category1"),
            Category(id: UUID(), name: "category2"),
            Category(id: UUID(), name: "category3"),
            Category(id: UUID(), name: "category4")
        ]
    }
    
    func addCategory(category: Category) {
        listOfCategories.append(category)
    }
    
    func updateCategory(category: Category) {
        for i in 0..<listOfCategories.count {
            if category.id == listOfCategories[i].id {
                listOfCategories[i] = category
                return
            }
        }
        print("updateCategory: category: \(category.id) not found")
    }
    
    func deleteCategory(category: Category) {
        for i in (0..<listOfCategories.count).reversed() {
            if category.id == listOfCategories[i].id {
                listOfCategories.remove(at: i)
                return
            }
        }
        print("deleteCategory: category: \(category.id) not found")
    }
    
    func getCategories() -> [Category] {
        return listOfCategories
    }
}
