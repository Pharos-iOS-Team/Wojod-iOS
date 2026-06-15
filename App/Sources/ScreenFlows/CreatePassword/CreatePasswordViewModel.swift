// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation
import Moya

class CreatePasswordViewModel: ModelDecodable {
    private var model = CreatePasswordModel()
    private let setPasswordApiClient = SetPasswordApiClient()
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
            setPasswordApiClient.setPassword(request: request) { response, error in
                if let response = response {
                    if response.statusCode < 300 {
                        self.handleSetPasswordSuccess(response: response)
                    } else {
                        self.decodeError(response: response) { result in
                            if case .failure(let error) = result { self.errorHandler?(error) }
                        }
                    }
                } else if let error = error {
                    self.handleMoyaError(error: error) { result in
                        if case .failure(let wjError) = result { self.errorHandler?(wjError) }
                    }
                }
            }
        } else {
            let passwordModel = ForgetPasswordModel(mobileNumber: mobileNumber, password: password, passwordConfirmation: passwordConfirmation)
            model.createPassword(password: passwordModel) { result in
                switch result {
                case .success:
                    self.successHandler?()
                case .failure(let error):
                    self.errorHandler?(error)
                }
            }
        }
    }

    private func handleSetPasswordSuccess(response: Response) {
        cacheAccessToken(headers: response.response?.allHeaderFields)
        decode(modelType: LoginApiResponseModel.self, from: response) { [weak self] result in
            switch result {
            case .success(let user as LoginApiResponseModel):
                User.shared.setUserData(user: user.data)
            case .failure(let error):
                print("⚠️ set_password user decode failed: \(error.message)")
            default:
                return
            }
            self?.successHandler?()
        }
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
