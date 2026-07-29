// Copyright © 2022 Pharos Solutions. All rights reserved.

import Foundation

extension NSObject {
    /// Check if the current account is used for testing
    func isTestingAccount() -> Bool {
        switch AppEnvironment.appName {
        case .royalMedicine:
            return User.shared.mobileNumber == "01280327476"
        case .squareCenter:
            return User.shared.mobileNumber == "01280327477"
        default:
            return User.shared.mobileNumber == "01280327473" 
        }
    }
}
