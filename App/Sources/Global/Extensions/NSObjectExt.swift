// Copyright © 2022 Pharos Solutions. All rights reserved.

import Foundation

extension NSObject {
    /// Check if the current account is used for testing
    func isTestingAccount() -> Bool {
        if AppEnvironment.appName == .royalMedicine {
            return User.shared.mobileNumber == "01280327476"
        } else if AppEnvironment.appName == .squareCenter {
            return User.shared.mobileNumber == "01206425333"
        } else {
            return User.shared.mobileNumber == "01280327473"
        }
    }
}
