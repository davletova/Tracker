//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Алия Давлетова on 28.08.2023.
//

import Foundation
import CoreData
import UIKit

enum TrackerCategoryStoreError: Error {
    case getCategoriesFailed
    case decodeCategoriesIdFailed
    case decodeCategoriesNameFailed
}


final class TrackerCategoryStore: NSObject {
    private let context: NSManagedObjectContext
    
    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        try! self.init(context: context)
    }

    init(context: NSManagedObjectContext) throws {
        self.context = context
        super.init()
        
        // Временный код для создания категорий
        // пока не реализован контроллер для создания категорий
        setupRecords(with: context)
    }
    
    private func setupRecords(with context: NSManagedObjectContext) {
        // Для того чтобы каждый раз не добавлять новые записи выполняем проверку
        // существуют ли записи.
        let checkRequest = TrackerCategoryCoreData.fetchRequest()
        let result = try! context.fetch(checkRequest)
        if result.count > 0 { return }
        
        let categories = [TrackerCategory(name: "category1"),
                       TrackerCategory(name: "category2"),
                       TrackerCategory(name: "category3"),
                       TrackerCategory(name: "category4")]
            .enumerated()
            .map { _, category in
                let categoryCoreData = TrackerCategoryCoreData(context: context)
                categoryCoreData.name = category.name
                return categoryCoreData
        }
    }
    
    func getCategories() throws -> [TrackerCategory]  {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.returnsObjectsAsFaults = false
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        guard let categories = try? context.fetch(request) else {
            throw TrackerCategoryStoreError.getCategoriesFailed
        }
        
        return categories.map({ try! makeTrackerCategory(from: $0) })
    }
    
    private func makeTrackerCategory(from trackerCategoryCoreData: TrackerCategoryCoreData) throws -> TrackerCategory {
        let categoryId = trackerCategoryCoreData.objectID.uriRepresentation().absoluteString
        guard let categoryName = trackerCategoryCoreData.name else {
            throw TrackerCategoryStoreError.decodeCategoriesNameFailed
        }
        
        var trackerCategory = TrackerCategory(name: categoryName)
        trackerCategory.id = categoryId
        
        return trackerCategory
    }
}
