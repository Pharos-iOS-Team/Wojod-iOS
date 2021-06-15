// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

class VerifyOtpViewModel {
    var mobileNumber: String = ""
    let model = VerifyOtpModel()

    var errorHandler: ((WJError) -> Void)?
    var successHandler: (() -> Void)?
    var showIndicator: (() -> Void)?

    func verifyOtp(otp: OtpVerification) {
        guard otp.otpCode.isValid else {
            let error = WJError(type: .validationError, message: L10n.Login.mobileNumberIsEmpty)
            errorHandler?(error)
            return
        }
        showIndicator?()
        model.verifyOtp(otp: otp) { result in
            switch result {
            case .success (let user as LoginApiResponseModel):
                User.shared.setUserData(user: user.data)
                self.successHandler?()
            case .failure(let error):
                self.errorHandler?(error)
            default:
                return
            }
        }
    }

    func verifyOtpFromLogin(otp: OtpVerification) {
        guard otp.otpCode.isValid else {
            let error = WJError(type: .validationError, message: L10n.Login.mobileNumberIsEmpty)
            errorHandler?(error)
            return
        }
        showIndicator?()
        model.verifyOtpFromLogin(otp: otp) { result in
            switch result {
            case .success (let user as LoginApiResponseModel):
                User.shared.setUserData(user: user.data)
                self.successHandler?()
            case .failure(let error):
                self.errorHandler?(error)
            default:
                return
            }
        }
    }
}
