// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

struct Grade {
    let currentMark: Double
    let totalMark: Double

    var description: String {
        let backSlash = Language.currentLanguage == .arabic ? #"\"# : "/"
        return "\(currentMarkFormatted)\(backSlash)\(totalMarkFormatted)"
    }

    var currentMarkFormatted: String {
        NumberFormatter.getDecimalFormattedString(fromDouble: currentMark) ?? "\(currentMark)"
    }

    var totalMarkFormatted: String {
        NumberFormatter.getDecimalFormattedString(fromDouble: totalMark) ?? "\(totalMark)"
    }
}
