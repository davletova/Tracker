//
//  Context.swift
//  Tracker
//
//  Created by Алия Давлетова on 27.08.2023.
//

import Foundation
import CoreData

extension NSManagedObjectContext {
    func safeSave() {
        if self.hasChanges {
            do {
                try self.save()
            } catch {
                print("failed to save context")
                self.rollback()
            }
        }
    }
}
