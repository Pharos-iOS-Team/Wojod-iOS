// Copyright © 2020 Pharos Solutions. All rights reserved.

import Foundation

struct DateFormatterHandler {
    static var shared = DateFormatterHandler()

    func formatStringDate(_ stringDate: String) -> String {
        guard let date = DateFormatter.iso8086DateFormatter.date(from: stringDate) else { return "" }
        return DateFormatter.mediumStyleDateFormatter.string(from: date)
    }

    func formatStringDateAndTime(_ stringDate: String) -> String {
        guard let date = DateFormatter.iso8086DateFormatter.date(from: stringDate) else { return "" }
        return DateFormatter.mediumStyleDateFormatter.string(from: date) + DateFormatter.timeDateFormatter.string(from: date)
    }

    func formatStringDate(numbersOnlydate: String) -> String {
        guard let date = DateFormatter.birthDateFormatter.date(from: numbersOnlydate) else { return "" }
        return DateFormatter.mediumStyleDateFormatter.string(from: date)
    }

    func formatStringDate(_ date: Date?) -> String {
        guard let date = date else { return "" }
        return DateFormatter.mediumStyleDateFormatter.string(from: date)
    }

    func formatStringDateToDateTimeForChat(_ stringDate: String) -> String {
        guard let date = DateFormatter.isoDateFormatter.date(from: stringDate) else { return "" }
        return DateFormatter.shortStyleDateFormatter.string(from: date)
    }
}
