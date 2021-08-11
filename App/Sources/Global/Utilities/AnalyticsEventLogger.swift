// Copyright © 2021 Pharos Solutions. All rights reserved.

import FirebaseAnalytics

let analytics = AnalyticsEventLogger.self

@objcMembers
final class AnalyticsEventLogger: NSObject {
    fileprivate enum EventType: String {
        case errorKey
    }

    static func log(error: String) {
        Analytics.log(.errorKey, parameters: [EventType.errorKey.rawValue: error])
    }
}

extension Analytics {
    fileprivate static func log(_ event: AnalyticsEventLogger.EventType, parameters: [String: String]) {
        Analytics.logEvent(event.rawValue, parameters: parameters)
    }
}
