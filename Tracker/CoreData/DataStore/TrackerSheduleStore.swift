//
//  TrackerSheduleCoreData.swift
//  Tracker
//
//  Created by Алия Давлетова on 18.09.2023.
//

import Foundation
import CoreData
import UIKit

final class TrackerScheduleStore: NSObject {
    private let context: NSManagedObjectContext
    
    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        try! self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) throws {
        self.context = context
        super.init()
    }
}

extension TrackerScheduleStore: ListScheduleProtocol {
    func listShedule() throws -> [TrackerScheduleCoreData] {
        let request = TrackerScheduleCoreData.fetchRequest()
        return try context.fetch(request)
    }
}
