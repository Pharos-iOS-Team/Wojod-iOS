// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

struct ForgetPasswordModel: Codable {
    var mobileNumber: String?
    var password: String?
    var passwordConfirmation: String?
}
