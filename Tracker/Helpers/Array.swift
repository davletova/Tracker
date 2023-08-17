//
//  Array.swift
//  Tracker
//
//  Created by Алия Давлетова on 03.08.2023.
//

import Foundation

extension Array {
    func safetyAccessElement(at index: Int) -> Element? {
        guard (0..<count).contains(index) else {
            return nil
        }

        return self[index]
    }
}
