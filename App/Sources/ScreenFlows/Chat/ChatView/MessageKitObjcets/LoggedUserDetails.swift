// Copyright © 2020 Pharos Solutions. All rights reserved.

import Foundation
import MessageKit
import SwiftyUserDefaults

struct LoggedUserDetails: SenderType {
    var senderId: String {
        "\(Defaults[\.userId] ?? 0)"
    }
    var displayName: String {
        ""
    }
}
