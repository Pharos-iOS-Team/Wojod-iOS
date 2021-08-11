// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation
import Reachability

extension Reachability {
    static var shared = try? Reachability()

    var reachable: Bool {
        connection != .unavailable
    }
}
