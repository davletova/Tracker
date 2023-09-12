//
//  Array.swift
//  Tracker
//
//  Created by Алия Давлетова on 03.08.2023.
//

import Foundation

extension Array {
    public subscript(at index: Int) -> Element? {
        guard index >= 0, index < endIndex else {
            return nil
        }

        return self[index]
    }
}
