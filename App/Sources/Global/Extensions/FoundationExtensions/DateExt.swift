// Copyright © 2020 Pharos Solutions. All rights reserved.

import Foundation

extension Date {
    var formattedDateString: String {
        let formatter = DateFormatter().with {
            $0.dateStyle = .medium
        }
        return formatter.string(from: self)
    }
}
