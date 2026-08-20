// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation
import SwiftyUserDefaults

class LoginViewModel {
    private var model = LoginModel()
    private(set) var mobileNumber: String = ""
    private var password: String = ""

    // MARK: - Country / Phone State
    private(set) var selectedCountryCode: String = PhoneNumberValidator.egyptCountryCode
    private(set) var selectedRegionCode: String = PhoneNumberValidator.egyptRegionCode

    init(mobileNumber: String = "", countryCode: String = PhoneNumberValidator.egyptCountryCode, regionCode: String = PhoneNumberValidator.egyptRegionCode) {
        self.mobileNumber = mobileNumber
        self.selectedCountryCode = countryCode
        self.selectedRegionCode = regionCode
    }

    // MARK: - Callbacks

    var errorHandler: ((WJError) -> Void)?
    var successHandler: ((UserModel) -> Void)?
    var showIndicator: (() -> Void)?
    var navigateToPasswordEntry: (() -> Void)?
    var navigateToOtpVerification: ((String, String) -> Void)?
    var setPassword: Bool = false

    // MARK: - Phone Input Update

    /// Called by the view whenever the user changes the phone number or country.
    func updatePhone(rawNumber: String, countryCode: String, regionCode: String) {
        mobileNumber = rawNumber
        selectedCountryCode = countryCode
        selectedRegionCode = regionCode
    }

    // MARK: - Submit Phone

    func submitPhoneNumber(mobileNumber: String?) {
        guard let number = mobileNumber else { return }
        self.mobileNumber = number
        guard number.isValid else {
            errorHandler?(WJError(type: .validationError, message: L10n.Login.mobileNumberIsEmpty))
            return
        }
        showIndicator?()
        model.verifyPhone(mobileNumber: number, countryCode: selectedCountryCode) { result in
            switch result {
            case .success(let response):
                self.setPassword = response.setPassword
                if self.setPassword {
                    self.requestOtpThenNavigate(mobileNumber: number)
                } else {
                    self.navigateToPasswordEntry?()
                }
            case .failure(let error):
                self.errorHandler?(self.mapToWJError(error))
            }
        }
    }

    private func requestOtpThenNavigate(mobileNumber: String) {
        model.resendOtpForLogin(mobileNumber: mobileNumber) { _ in
            self.navigateToOtpVerification?(mobileNumber, self.selectedCountryCode)
        }
    }

    // MARK: - Login with Password

    func checkIfMobileOrPasswordAreEmpty() -> Bool {
        return mobileNumber.isValid && password.isValid
    }

    func login(mobileNumber: String?, password: String?) {
        guard let number = mobileNumber, let password = password else { return }
        self.mobileNumber = number
        self.password = password
        guard number.isValid && password.isValid else {
            errorHandler?(WJError(type: .validationError, message: getAlertMessage()))
            return
        }
        showIndicator?()
        print("here >>> \(selectedCountryCode) and \(number)")
        model.login(mobileNumber: number, password: password, countryCode: selectedCountryCode) { result in
            switch result {
            case .success(let user):
                self.setUserData(user: user.data)
                self.successHandler?(user.data)
            case .failure(let error):
                self.errorHandler?(self.mapToWJError(error))
            }
        }
    }

    // MARK: - Guest Mode
    func isGuestModeEnabled(completion: @escaping (Bool) -> Void) {
        model.guestMode { result in
            switch result {
            case .success(let whiteLabelVersion):
                completion(whiteLabelVersion.version == "1.0.0")
            case .failure(let error):
                self.errorHandler?(self.mapToWJError(error))
                completion(false)
            }
        }
    }

    func continueAsAGuest() {
        showIndicator?()
        Defaults[\.isGuestModeEnabled] = true
        User.shared.setLoggedIn(token: "W_GPhQnZ6OztX4TVu5rQAA", client: "F2PewhGD4cBb43ltw31Jjw", uid: "01206425399")
        if let user = model.loadGuestModelUserData() {
            self.setUserData(user: user)
            self.successHandler?(user)
        }
    }

    // MARK: - Helpers
    func getAlertMessage() -> String {
        if mobileNumber.isValid && !password.isValid {
            return L10n.Login.passwordIsEmpty
        } else if !mobileNumber.isValid && password.isValid {
            return L10n.Login.mobileNumberIsEmpty
        } else {
            return L10n.Login.bothAreEmpty
        }
    }

    private func setUserData(user: UserModel) {
        User.shared.setUserData(user: user)
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

    func doesErrorIndicateVerificationRequired(_ error: WJError) -> Bool {
        if case .serverSideError(statusCode: let statusCode) = error.type, statusCode == .unprocessableEntity {
            return true
        }
        return false
    }
}
