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
    case getCategoryFailed
    case decodeCategoriesIdFailed
    case decodeCategoriesNameFailed
    case generateURLError
    case emptyCategoryID
}

final class TrackerCategoryStore: NSObject {
    private let context: NSManagedObjectContext
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "name", ascending: true)
        ]
        
        return NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
    }()
    
    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        try! self.init(context: context)
    }

    init(context: NSManagedObjectContext) throws {
        self.context = context
        super.init()
        
        self.fetchedResultsController.delegate = self
        
        try fetchedResultsController.performFetch()
    }
    
    private func makeTrackerCategory(from trackerCategoryCoreData: TrackerCategoryCoreData) throws -> TrackerCategory {
        guard let categoryName = trackerCategoryCoreData.name else {
            throw TrackerCategoryStoreError.decodeCategoriesNameFailed
        }
        guard let categoryID = trackerCategoryCoreData.categoryID else {
            throw TrackerCategoryStoreError.decodeCategoriesIdFailed
        }
        
        let trackerCategory = TrackerCategory(id: categoryID, name: categoryName)
        
        return trackerCategory
    }
}

extension TrackerCategoryStore: TrackerCategoryStoreProtocol {
    func getCategories() throws -> [TrackerCategoryCoreData]  {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.returnsObjectsAsFaults = false
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
      
        return try context.fetch(request)
    }
    
    func addNewCategory(_ category: TrackerCategory) throws {
        let trackerCategoryCoreData = TrackerCategoryCoreData(context: context)
        trackerCategoryCoreData.name = category.name
        trackerCategoryCoreData.categoryID = category.id
        
        context.safeSave()
    }
    
    func deleteCategory(_ categoryID: UUID) throws {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.returnsObjectsAsFaults = false
        
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCategoryCoreData.categoryID), categoryID.uuidString)
        guard let categories = try? context.fetch(request) else {
            throw TrackerCategoryStoreError.getCategoryFailed
        }
        if categories.count < 1 || categories.count > 1 {
            throw TrackerCategoryStoreError.getCategoryFailed
        }
        
        context.delete(categories[0])
    }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        NotificationCenter.default.post(
            name: ListCategoriesViewModel.TrackerCategorySavedNotification,
            object: self
        )
    }
}
