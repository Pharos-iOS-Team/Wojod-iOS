// Copyright © 2022 Pharos Solutions. All rights reserved.

import Foundation

extension NSObject {
    /// Check if the current account is used for testing
    func isTestingAccount() -> Bool {
        return User.shared.mobileNumber == "01280327473"
    }
}
