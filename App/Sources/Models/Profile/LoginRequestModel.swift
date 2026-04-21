// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

struct LoginRequestModel: Encodable {
    var mobileNumber: String
    var password: String
    var locale: String = Language.currentLanguage.rawValue
    var deviceId: String = UIDevice.current.identifierForVendor?.uuidString ?? ""
    var loginOrganization: String? = AppEnvironment.appName.loginOrganization
}
