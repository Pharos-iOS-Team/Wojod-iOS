// Copyright © 2025 Pharos Solutions. All rights reserved.

import Foundation

struct GetOTPRequestModel: Encodable {
    var mobileNumber: String
    var countryCode: String?
    var provider: OTPProvider?
    var isRoyalMedicineStudent: Bool = AppEnvironment.appName == .royalMedicine
    var loginOrganization: String? = AppEnvironment.appName.loginOrganization
}
