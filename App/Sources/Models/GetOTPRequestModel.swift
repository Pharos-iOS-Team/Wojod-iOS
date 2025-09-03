// Copyright © 2025 Pharos Solutions. All rights reserved.

import Foundation

struct GetOTPRequestModel: Encodable {
    var mobileNumber: String
    var isRoyalMedicineStudent: Bool = Environment.appName == .royalMedicine
}
