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
    private var categories: [Category]
    
    init() {
        categories = mockCategories
    }
    
    func addCategory(category: Category) {
        categories.append(category)
    }
    
    func updateCategory(category: Category) {
        for i in 0..<categories.count {
            if category.id == categories[i].id {
                categories[i] = category
                return
            }
        }
        print("updateCategory: category: \(category.id) not found")
    }
    
    func deleteCategory(category: Category) {
        for i in (0..<categories.count).reversed() {
            if category.id == categories[i].id {
                categories.remove(at: i)
                return
            }
        }
        print("deleteCategory: category: \(category.id) not found")
    }
    
    func getCategories() -> [Category] {
        return categories
    }
    
    
    
}
