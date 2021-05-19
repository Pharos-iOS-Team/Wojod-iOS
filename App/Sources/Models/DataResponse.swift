// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

internal struct DataResponse: Codable {
    internal let data: [KeyName]
    internal let totalCount: Int
}
