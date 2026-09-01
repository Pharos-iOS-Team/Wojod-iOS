// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation
import PhoneNumberKit

class VerifyOtpViewModel {
    let model = VerifyOtpModel()
    var mobileNumber: String = ""
    var otp: String = ""
    var otpProvider: OTPProvider = .whatsapp
    var verifyUserFromLogin: Bool = false
    var hideBackButton: Bool = false
    var shouldSendButtonBeUnabled: Bool = false
    var hasResentOTP: Bool = false
    var resendCooldownDuration: Int = 180

    var countryCode: String = PhoneNumberValidator.egyptCountryCode {
        didSet { regionCode = regionCodeFromDialCode(countryCode) }
    }
    private(set) var regionCode: String = PhoneNumberValidator.egyptRegionCode

    init(
        mobileNumber: String = "",
        countryCode: String = PhoneNumberValidator.egyptCountryCode,
        otpProvider: OTPProvider = .whatsapp,
        verifyUserFromLogin: Bool = false,
        hideBackButton: Bool = false,
        successHandler: (() -> Void)? = nil
    ) {
        self.mobileNumber = mobileNumber
        self.countryCode = countryCode
        self.otpProvider = otpProvider
        self.verifyUserFromLogin = verifyUserFromLogin
        self.hideBackButton = hideBackButton
        self.successHandler = successHandler
    }

    // MARK: - Callbacks

    var errorHandler: ((WJError) -> Void)?
    var successHandler: (() -> Void)?
    var showIndicator: (() -> Void)?
    var resendSuccessHandler: (() -> Void)?

    // MARK: - OTP Verification

    func verifyOtp(otp: OtpVerification) {
        guard otp.otpCode.isValid else {
            errorHandler?(WJError(type: .validationError, message: L10n.Login.mobileNumberIsEmpty))
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
            errorHandler?(WJError(type: .validationError, message: L10n.Login.mobileNumberIsEmpty))
            return
        }
        showIndicator?()
        model.verifyOtpFromLogin(otp: otp) { result in
            switch result {
            case .success(let user):
                if let user { User.shared.setUserData(user: user) }
                self.successHandler?()
            case .failure(let error):
                self.errorHandler?(self.mapToWJError(error))
            }
        }
    }

    // MARK: - Resend OTP
    func resendOTP() {
        let provider: OTPProvider = regionCode.uppercased() == PhoneNumberValidator.egyptRegionCode ? .sms : .whatsapp
        model.resendOTP(mobileNumber: mobileNumber, countryCode: countryCode, provider: provider) { [weak self] result in
            switch result {
            case .success:
                self?.resendSuccessHandler?()
            case .failure(let error):
                self?.errorHandler?(self?.mapToWJError(error) ?? WJError(type: .parsingError, message: error.localizedDescription))
            }
        }
    }

    // MARK: - Private

    private func regionCodeFromDialCode(_ dialCode: String) -> String {
        let digits = dialCode.hasPrefix("+") ? String(dialCode.dropFirst()) : dialCode
        guard let numeric = UInt64(digits) else { return PhoneNumberValidator.egyptRegionCode }
        return PhoneNumberUtility().mainCountry(forCode: numeric) ?? PhoneNumberValidator.egyptRegionCode
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
}
