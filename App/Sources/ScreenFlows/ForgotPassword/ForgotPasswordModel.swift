// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

class ForgotPasswordModel {
    private let apiClient = ForgotPasswordApiClient()

    func sendMobileNumber(mobileNumber: String) {
        apiClient.sendMobileNumber(mobileNumber: mobileNumber) { response, error in
        }
    }
}
