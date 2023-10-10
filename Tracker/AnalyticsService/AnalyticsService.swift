//
//  AnalyticsService.swift
//  Tracker
//
//  Created by Алия Давлетова on 15.09.2023.
//

import Foundation
import YandexMobileMetrica

final class AnalyticsService {
    static func sendEvent(event: String, screen: String, item: String? = nil) {
        var params : [AnyHashable : Any] = ["event": event, "screen": screen]
        if let item = item {
            params["item"] = item
        }
        YMMYandexMetrica.reportEvent("EVENT", parameters: params, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }
}
