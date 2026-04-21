// Copyright © 2026 Pharos Solutions. All rights reserved.

import Foundation

struct SetPasswordRequest: Encodable {
    let password: String
    let passwordConfirmation: String
    var locale: String = Language.currentLanguage.rawValue
    var deviceId: String = UIDevice.current.identifierForVendor?.uuidString ?? ""
    var loginOrganization: String? = AppEnvironment.appName.loginOrganization
}
