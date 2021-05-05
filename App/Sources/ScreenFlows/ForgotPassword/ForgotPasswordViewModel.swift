// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

class ForgotPasswordViewModel {
    private var model = ForgotPasswordModel()
    private var mobileNumber: String = ""

    var errorHandler: ((WJError) -> Void)?
    var successHandler: (() -> Void)?
    var showIndicator: (() -> Void)?

    func sendMobileNumber(mobileNumber: String?) {
        guard let mobileNumber = mobileNumber else { return }
        self.mobileNumber = mobileNumber
        guard mobileNumber.isValid else {
            let error = WJError(type: .validationError, message: L10n.Login.mobileNumberIsEmpty)
            errorHandler?(error)
            return
        }
        showIndicator?()
        model.sendMobileNumber(mobileNumber: mobileNumber) { result  in
            switch result {
            case .success:
                self.successHandler?()
            case .failure(let error):
                self.errorHandler?(error)
            }
        }
    }
}
