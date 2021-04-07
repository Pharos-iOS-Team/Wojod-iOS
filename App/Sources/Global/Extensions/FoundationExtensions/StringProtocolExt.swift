// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

extension StringProtocol {
    var trimmed: String {
        return trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
}
