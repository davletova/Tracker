//
//  TrackerRecordProtocol.swift
//  Tracker
//
//  Created by Алия Давлетова on 28.08.2023.
//

import Foundation

protocol TrackerRecordStoreProtocol: AnyObject {
    func addNewRecord(_ trackerRecord: TrackerRecord) throws
    func deleteRecord(_ trackerRecord: TrackerRecord) throws
}
