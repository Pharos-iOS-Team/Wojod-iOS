// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation
import SwiftyUserDefaults

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

    func isGuestModeEnabled(completion: @escaping (Bool) -> Void) {
        model.guestMode { result in
            switch result {
            case .success(let whiteLabelVersion as VersionResponse):
                let isGuestModeEnabled = whiteLabelVersion.version == "1.0.0"
                completion(isGuestModeEnabled)
            case .failure(let error):
                self.errorHandler?(error)
                completion(false)
            default:
                completion(false)
            }
        }
    }

    func continueAsAGuest() {
        showIndicator?()
        Defaults[\.isGuestModeEnabled] = true
        User.shared.setLoggedIn(token: "a4IR4BjdJfMb0Rpn-dJ_JA", client: "jSU8ziSjawbDRFQTfVoBAg", uid: "01206425318")
        if let user = model.loadLoginResponse() {
            self.setUserData(user: user, studentUser: nil)
            self.successHandler?(user)
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
