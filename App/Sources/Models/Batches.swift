// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

struct BatchesModel: Codable {
    var batches: [Batch]
}

struct Batch: Codable {
    var key: Int?
    var value: String?
}
