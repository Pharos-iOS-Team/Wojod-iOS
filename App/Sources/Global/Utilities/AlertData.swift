// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

struct AlertData {
    var title: String
    var message: String
    var shouldDiscard: Bool

    init(title: String, message: String, shouldDiscard: Bool) {
        self.title = title
        self.message = message
        self.shouldDiscard = shouldDiscard
    }
}
