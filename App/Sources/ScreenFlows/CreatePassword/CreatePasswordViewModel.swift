// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

class CreatePasswordViewModel {
    private var model = CreatePasswordModel()
    private var mobileNumber: String = ""
    private var password: String = ""
    private var passwordConfirmation: String = ""

    var isActivationFlow: Bool = false
    var errorHandler: ((WJError) -> Void)?
    var successHandler: (() -> Void)?
    var showIndicator: (() -> Void)?

    func checkIfMobileOrPasswordAreEmpty() -> Bool {
        return mobileNumber.isValid && password.isValid
    }

    func createPassword(mobileNumber: String?, password: String?, passwordConfirmation: String?) {
        guard let number = mobileNumber, let password = password, let passwordConfirmation = passwordConfirmation else { return }
        self.mobileNumber = number
        self.password = password
        self.passwordConfirmation = passwordConfirmation
        guard validatePassword() else { return }
        showIndicator?()
        if isActivationFlow {
            let request = SetPasswordRequest(password: password, passwordConfirmation: passwordConfirmation)
            ApiProvider.shared.request(.auth(.setPassword(request))) { result in
                switch result {
                case .success(let response):
                    if let user = try? JSONDecoder.default.decode(ApiResponse<UserModel>.self, from: response.data) {
                        User.shared.setUserData(user: user.data)
                    }
                    self.successHandler?()
                case .failure(let error):
                    self.errorHandler?(self.mapToWJError(error))
                }
            }
        } else {
            let passwordModel = ForgetPasswordModel(mobileNumber: mobileNumber, password: password, passwordConfirmation: passwordConfirmation)
            model.createPassword(password: passwordModel) { result in
                switch result {
                case .success:
                    self.successHandler?()
                case .failure(let error):
                    self.errorHandler?(self.mapToWJError(error))
                }
            }
        }
    }

    private func mapToWJError(_ error: Error) -> WJError {
        if let apiError = error as? ApiError,
           case .clientError(let statusCode, let endpointError) = apiError {
            return WJError(
                type: .serverSideError(statusCode: HTTPStatusCode(rawValue: statusCode)),
                message: endpointError.errors.first ?? ""
            )
        }
        return WJError(type: .parsingError, message: error.localizedDescription)
    }

    func validatePassword() -> Bool {
        guard passwordConfirmation.isValid && password.isValid else {
            let error = WJError(type: .validationError, message: getAlertMessage())
            errorHandler?(error)
            return false
        }
        guard passwordConfirmation == password else {
            let error = WJError(type: .validationError, message: getAlertMessage())
            errorHandler?(error)
            return false
        }

        guard password.count >= 6 else {
            let error = WJError(type: .validationError, message: getAlertMessage())
            errorHandler?(error)
            return false
        }
        return true
    }

    func getAlertMessage() -> String {
        if password.isValid && !passwordConfirmation.isValid {
            return L10n.CreatePassword.bothAreEmpty
        } else if !password.isValid && passwordConfirmation.isValid {
            return L10n.CreatePassword.bothAreEmpty
        } else if  password.isValid && password.count < 6 {
            return L10n.CreatePassword.passwordLengthTooShort
        } else if password != passwordConfirmation {
            return L10n.CreatePassword.passwordsDontMatch
        } else if !password.isValid && !passwordConfirmation.isValid {
            return L10n.CreatePassword.bothAreEmpty
        } else {
            return ""
        }
    }
}
