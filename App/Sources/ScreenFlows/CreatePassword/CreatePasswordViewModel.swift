// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

class CreatePasswordViewModel {
    private var model = CreatePasswordModel()
    private var mobileNumber: String = ""
    private var password: String = ""
    private var passwordConfirmation: String = ""

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
        let passwordModel = Password(mobileNumber: mobileNumber, password: password, passwordConfirmation: passwordConfirmation)
        model.createPassword(password: passwordModel) { result in
            switch result {
            case .success:
                self.successHandler?()
            case .failure(let error):
                self.errorHandler?(error)
            }
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
