//
//  ListCategoriesViewModel.swift
//  Tracker
//
//  Created by Алия Давлетова on 02.09.2023.
//

import Foundation

final class ListCategoriesViewModel {
    static let TrackerCategorySavedNotification = Notification.Name(rawValue: "CreateCategory")
    
    @Observable
    private (set) var listOfCategories = [TrackerCategoryViewModal]()
    
    @Observable
    private(set) var selectedCategory: TrackerCategory?
    
    private let store: TrackerCategoryStoreProtocol
    
    init() {
        store = TrackerCategoryStore()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateListOfCategories),
            name: ListCategoriesViewModel.TrackerCategorySavedNotification,
            object: nil
        )
        
        updateListOfCategories()
    }
    
    @objc func updateListOfCategories() {
        listOfCategories = getTrackerCategories()
    }
    
    func addTrackerCategory(category: TrackerCategory) {
        do {
            try store.addNewCategory(category)
        } catch {
            print("add tracker category failed with error \(error)")
        }
    }

    func deleteTrackerCategory(category: TrackerCategory) {
        do {
            try store.deleteCategory(category.id)
        } catch {
            print("delete category failed with error \(error)")
        }
    }
    
    func selectTrackerCategory(indexPath: IndexPath) {
        guard let category = listOfCategories.safetyAccessElement(at: indexPath.row) else {
            assertionFailure("failed to get category from viewModel.listOfCategories by index \(indexPath)")
            return
        }
        selectedCategory = TrackerCategory(id: category.id, name: category.name)
    }
    
    private func getTrackerCategories() -> [TrackerCategoryViewModal] {
        guard let categoriesCoreData = try? store.getCategories() else {
            print("failed to get catgories from store")
            return [TrackerCategoryViewModal]()
        }
                
        return categoriesCoreData.map{
            TrackerCategoryViewModal(
                id: $0.categoryID ?? UUID(),
                name: $0.name ?? ""
            )
        }
    }
}
