// Copyright © 2026 Pharos Solutions. All rights reserved.

import Foundation

struct CheckNumberRequestModel: Encodable {
    let mobileNumber: String
    let email: String
    let countryCode: String?
}
