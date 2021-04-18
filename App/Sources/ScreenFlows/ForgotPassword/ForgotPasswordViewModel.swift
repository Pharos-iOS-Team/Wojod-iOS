// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

class ForgotPasswordViewModel {
    private var model = ForgotPasswordModel()
    private var mobileNumber = ""

    var errorHandler: ((WJError) -> Void)?

    func sendMobileNumber(mobileNumber: String?) {
        guard let mobileNumber = mobileNumber else { return }
        self.mobileNumber = mobileNumber
        guard mobileNumber.isValid else {
            let error = WJError(type: .validationError, message: L10n.Login.mobileNumberIsEmpty)
            errorHandler?(error)
            return
        }
        model.sendMobileNumber(mobileNumber: mobileNumber)
    }
}
