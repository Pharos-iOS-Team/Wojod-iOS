// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

struct DivisionsModel: Codable {
    var divisions: [Division]
}

struct Division: Codable {
    var key: Int?
    var value: String?
}
