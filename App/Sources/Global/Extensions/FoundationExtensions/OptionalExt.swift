// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

extension Optional where Wrapped == String {
    var isBlank: Bool {
        guard let self = self else { return true }
        return self.isEmpty
    }

    var isValid: Bool {
        guard let self = self else { return false }
        return !self.isEmpty && !self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
