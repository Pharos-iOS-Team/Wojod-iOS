// Copyright © 2020 Pharos Solutions. All rights reserved.

import Foundation
import HandySwift

extension DateFormatter {
    static var isoDateFormatter: DateFormatter {
        return DateFormatter().with {
            $0.locale = Language.locale
            $0.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        }
    }

    static var iso8086DateFormatter: DateFormatter {
        return DateFormatter().with {
            $0.locale = Language.locale
            $0.timeZone = TimeZone(identifier: "UTC")
            $0.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        }
    }

    static var birthDateFormatter: DateFormatter {
        return DateFormatter().with {
            $0.locale = Language.locale
            $0.timeZone = .current
            $0.dateFormat = "yyyy-MM-dd"
        }
    }

    static var mediumStyleDateFormatter: DateFormatter {
        return DateFormatter().with {
            $0.dateFormat = "dd MMM yyyy"
            $0.timeZone = .current
            $0.locale = Language.locale
        }
    }

    static var timeDateFormatter: DateFormatter {
        return DateFormatter().with {
            $0.dateFormat = ", h:mm a"
            $0.timeZone = .current
            $0.locale = Language.locale
        }
    }

    static var shortStyleDateFormatter: DateFormatter {
        return DateFormatter().with {
            $0.dateFormat = "dd MMM, h:mm a"
            $0.timeZone = .current
            $0.locale = Language.locale
        }
    }
}
