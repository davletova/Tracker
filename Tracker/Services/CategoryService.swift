////
////  CategoryService.swift
////  Tracker
////
////  Created by Алия Давлетова on 09.08.2023.
////
//
//import Foundation
//
//protocol CategoryServiceProtocol {
//    func addCategory(category: TrackerCategory)
//    func updateCategory(category: TrackerCategory)
//    func deleteCategory(category: TrackerCategory)
//    func getCategories() -> [TrackerCategory]
//}
//
//final class CategoryService: CategoryServiceProtocol {
//    private var listOfCategories: [TrackerCategory]
//
//    init() {
//        listOfCategories = [
//            TrackerCategory(name: "category1"),
//            TrackerCategory(name: "category2"),
//            TrackerCategory(name: "category3"),
//            TrackerCategory(name: "category4")
//        ]
//    }
//
//    func addCategory(category: TrackerCategory) {
//        listOfCategories.append(category)
//    }
//
//    func updateCategory(category: TrackerCategory) {
//        for i in 0..<listOfCategories.count {
//            if category.id == listOfCategories[i].id {
//                listOfCategories[i] = category
//                return
//            }
//        }
//        print("updateCategory: category: \(category.id) not found")
//    }
//
//    func deleteCategory(category: TrackerCategory) {
//        for i in (0..<listOfCategories.count).reversed() {
//            if category.id == listOfCategories[i].id {
//                listOfCategories.remove(at: i)
//                return
//            }
//        }
//        print("deleteCategory: category: \(category.id) not found")
//    }
//
//    func getCategories() -> [TrackerCategory] {
//        return listOfCategories
//    }
//}
