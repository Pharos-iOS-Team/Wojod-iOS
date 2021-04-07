// Copyright © 2020 Pharos Solutions. All rights reserved.

import Foundation

enum Currency: String {
    case none = ""
    case sar = "EGP"
}

extension NumberFormatter {
    static var currencyFormatter: NumberFormatter {
        return NumberFormatter().with {
            $0.numberStyle = .currency
            $0.locale = Language.locale
            $0.nilSymbol = "-"
            $0.alwaysShowsDecimalSeparator = false
        }
    }

    static var localizedFormatter: NumberFormatter {
        return NumberFormatter().with {
            $0.numberStyle = .decimal
            $0.locale = Language.locale
            $0.roundingMode = .halfUp
            $0.maximumFractionDigits = 2
        }
    }

    static func localizedString(from string: String?) -> String? {
        guard let string = string, let double = Double(string) else { preconditionFailure("String not in correct format") }
        return localizedFormatter.string(for: double)
    }
}
