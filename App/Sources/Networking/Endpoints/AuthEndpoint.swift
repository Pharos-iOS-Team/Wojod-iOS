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
        }
    }

    var method: Moya.Method {
        switch self {
        case .login, .sendMobileNumber, .verifyOtp, .verifyOtpFromLogin:
            return .post
        case .guestMode:
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
        case let .sendMobileNumber(otp):
            return .requestCustomJSONEncodable(otp, encoder: .default)
        case let .verifyOtp(otp):
            return .requestCustomJSONEncodable(otp, encoder: .default)
        case let .verifyOtpFromLogin(otp):
            return .requestCustomJSONEncodable(otp, encoder: .default)
        case let .createPassword(password):
            return .requestCustomJSONEncodable(password, encoder: .default)
        }
    }
}
