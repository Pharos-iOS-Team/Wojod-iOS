// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

class ForgotPasswordViewModel {
    private var model = ForgotPasswordModel()
    private(set) var mobileNumber: String = ""

    // MARK: - Country / Phone State
    private(set) var selectedCountryCode: String = PhoneNumberValidator.egyptCountryCode
    private(set) var selectedRegionCode: String = PhoneNumberValidator.egyptRegionCode

    // MARK: - Callbacks

    var errorHandler: ((WJError) -> Void)?
    var successHandler: (() -> Void)?
    var showIndicator: (() -> Void)?

    // MARK: - Phone Input Update

    func updatePhone(rawNumber: String, countryCode: String, regionCode: String) {
        mobileNumber = rawNumber
        selectedCountryCode = countryCode
        selectedRegionCode = regionCode
    }

    // MARK: - Send OTP

    func sendMobileNumber(mobileNumber: String?) {
        guard let mobileNumber = mobileNumber, mobileNumber.isValid else {
            errorHandler?(WJError(type: .validationError, message: L10n.Login.mobileNumberIsEmpty))
            return
        }
        self.mobileNumber = mobileNumber
        showIndicator?()

        model.sendMobileNumber(mobileNumber: mobileNumber, countryCode: selectedCountryCode) { result in
            switch result {
            case .success:
                self.successHandler?()
            case .failure(let error):
                self.errorHandler?(WJError(type: .parsingError, message: error.localizedDescription))
            }
        }
    }
}
