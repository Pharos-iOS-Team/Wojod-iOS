// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

class LoginViewModel {
    private var model = LoginModel()
    private var mobileNumber: String = ""
    private var password: String = ""

    var errorHandler: ((WJError) -> Void)?
    var successHandler: ((LoginApiResponseModel) -> Void)?
    var showIndicator: (() -> Void)?

    func checkIfMobileOrPasswordAreEmpty() -> Bool {
        return mobileNumber.isValid && password.isValid
    }

    func login(mobileNumber: String?, password: String?) {
        guard let number = mobileNumber, let password = password else { return }
        self.mobileNumber = number
        self.password = password
        guard number.isValid && password.isValid else {
            let error = WJError(type: .validationError, message: getAlertMessage())
            errorHandler?(error)
            return
        }
        showIndicator?()
        model.login(mobileNumber: number, password: password) { result in
            switch result {
            case .success(let user as LoginApiResponseModel):
                self.setUserData(user: user, studentUser: nil)
                self.successHandler?(user)
            case .failure(let error):
                self.errorHandler?(error)
            default:
                return
            }
        }
    }

    func getAlertMessage() -> String {
        if mobileNumber.isValid && !password.isValid {
            return L10n.Login.passwordIsEmpty
        } else if !mobileNumber.isValid && password.isValid {
            return L10n.Login.mobileNumberIsEmpty
        } else {
            return L10n.Login.bothAreEmpty
        }
    }

    private func setUserData(user: LoginApiResponseModel?, studentUser: StudentModel?) {
        User.shared.setUserData(user: user != nil ? user?.data : studentUser?.student)
    }

    func doesErrorIndicateVerificationRequired(_ error: WJError) -> Bool {
        if case .serverSideError(statusCode: let statusCode) = error.type, statusCode == .unprocessableEntity {
            return true
        }
        return false
    }
}
