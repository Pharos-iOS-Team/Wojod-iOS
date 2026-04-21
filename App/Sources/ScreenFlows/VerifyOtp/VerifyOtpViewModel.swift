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
            case .success:
                self.successHandler?()
            case .failure(let error):
                self.errorHandler?(self.mapToWJError(error))
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
            case .success(let user):
                if let user = user {
                    User.shared.setUserData(user: user)
                }
                self.successHandler?()
            case .failure(let error):
                self.errorHandler?(self.mapToWJError(error))
            }
        }
    }

    private func mapToWJError(_ error: Error) -> WJError {
        if
            let apiError = error as? ApiError,
            case .clientError(let statusCode, let endpointError) = apiError {
            return WJError(
                type: .serverSideError(statusCode: HTTPStatusCode(rawValue: statusCode)),
                message: endpointError.errors.first ?? ""
            )
        }
        return WJError(type: .parsingError, message: error.localizedDescription)
    }
}
