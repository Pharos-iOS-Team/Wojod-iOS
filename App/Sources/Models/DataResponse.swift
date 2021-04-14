// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

internal struct DataResponse: Codable {
    private enum CodingKeys: String, CodingKey {
        case data
        case totalCount = "total_count"
    }

    internal let data: [KeyName]
    internal let totalCount: Int
}
