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
        let categoryId = trackerCategoryCoreData.objectID.uriRepresentation().absoluteString
        guard let categoryName = trackerCategoryCoreData.name else {
            throw TrackerCategoryStoreError.decodeCategoriesNameFailed
        }
        
        var trackerCategory = TrackerCategory(name: categoryName)
        trackerCategory.id = categoryId
        
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
        
        context.safeSave()
    }
    
    func deleteCategory(_ categoryID: String) throws {
        guard let idString = URL(string: categoryID) else {
            throw TrackerCategoryStoreError.generateURLError
        }
        
        guard let objectId = context.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: idString) else {
            throw TrackerCategoryStoreError.getCategoryFailed
        }
        
        guard let category = try context.existingObject(with: objectId) as? TrackerCategoryCoreData else {
            throw TrackerCategoryStoreError.decodeCategoriesIdFailed
        }
        
        context.delete(category)
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
