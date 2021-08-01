// Copyright © 2020 Pharos Solutions. All rights reserved.

import Foundation

extension Date {
    var formattedDateString: String {
        let formatter = DateFormatter().with {
            $0.dateStyle = .medium
        }
        return formatter.string(from: self)
    }

    var formatDateToDateTimeString: String {
        return DateFormatter.shortStyleDateFormatter.string(from: self)
    }

    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }

    var endOfDay: Date? {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)
    }

    func formatted(with dateFormat: String, _ forEvents: Bool = false) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        formatter.locale = Locale(identifier: forEvents ? "en" : Language.currentLanguage.rawValue)
        return formatter.string(from: self)
    }
}
