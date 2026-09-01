// Copyright © 2026 Pharos Solutions. All rights reserved.

import Foundation
import Moya

enum AuthEndpoint {
    case login(LoginRequestModel)
    case guestMode(GuestModeRequestModel)
    case logout(LogoutRequestModel)
    case sendMobileNumber(GetOTPRequestModel)
    case verifyOtp(OtpVerification)
    case verifyOtpFromLogin(OtpVerification)
    case createPassword(ForgetPasswordModel)
    case verifyPhone(VerifyPhoneRequestModel)
    case resendOtpForLogin(mobileNumber: String)
    case setPassword(SetPasswordRequest)
}

extension AuthEndpoint: TargetType {
    var path: String {
        switch self {
        case .login:
            return "/auth/sign_in"
        case .guestMode:
            return "/white_label_version"
        case .logout:
            return "/auth/sign_out"
        case .sendMobileNumber:
            return "/password/send_otp"
        case .verifyOtp:
            return "/password/verify_otp"
        case .verifyOtpFromLogin:
            return "/verify_otp"
        case .createPassword:
            return "/password"
        case .verifyPhone:
            return "/auth/verify_phone"
        case .resendOtpForLogin:
            return "/resend_otp"
        case .setPassword:
            return "/auth/set_password"
        }
    }

    var method: Moya.Method {
        switch self {
        case .login, .sendMobileNumber, .verifyOtp, .verifyOtpFromLogin, .verifyPhone, .setPassword:
            return .post
        case .guestMode, .resendOtpForLogin:
            return .get
        case .logout:
            return .delete
        case .createPassword:
            return .put
        }
    }

    var task: Task {
        switch self {
        case let .login(loginRequestModel):
            return .requestCustomJSONEncodable(loginRequestModel, encoder: .default)
        case let .guestMode(requestModel):
            return .queryParameters(requestModel)
        case let .logout(requestModel):
            return .queryParameters(requestModel)
        case let .sendMobileNumber(model):
            return .requestCustomJSONEncodable(model, encoder: .default)
        case let .verifyOtp(otp):
            return .requestCustomJSONEncodable(otp, encoder: .default)
        case let .verifyOtpFromLogin(otp):
            return .requestCustomJSONEncodable(otp, encoder: .default)
        case let .createPassword(password):
            return .requestCustomJSONEncodable(password, encoder: .default)
        case let .verifyPhone(requestModel):
            return .requestCustomJSONEncodable(requestModel, encoder: .default)
        case let .resendOtpForLogin(mobileNumber):
            return .requestParameters(parameters: ["mobile_number": mobileNumber], encoding: URLEncoding.queryString)
        case let .setPassword(request):
            return .requestCustomJSONEncodable(request, encoder: .default)
        }
    }
}
