// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation
import Moya

enum LoginTarget {
    case login(loginRequestModel: LoginRequestModel)
    case guestMode(appName: String)
    case verifyPhone(requestModel: VerifyPhoneRequestModel)
    case resendOtpForLogin(mobileNumber: String)
}

extension LoginTarget: TargetType {
    var path: String {
        switch self {
        case .login:
            return "/auth/sign_in"
        case .guestMode:
            return "/white_label_version"
        case .verifyPhone:
            return "/auth/verify_phone"
        case .resendOtpForLogin:
            return "/resend_otp"
        }
    }

    var method: Moya.Method {
        switch self {
        case .login:
            return .post
        case .guestMode:
            return .get
        case .verifyPhone:
            return .post
        case .resendOtpForLogin:
            return .get
        }
    }

    var task: Task {
        switch self {
        case let .login(loginRequestModel):
            return .requestCustomJSONEncodable(loginRequestModel, encoder: JSONEncoder.default)
        case let .guestMode(appName):
            return .requestParameters(
                parameters: ["app_name": appName],
                encoding: URLEncoding.queryString
            )
        case let .verifyPhone(verifyPhoneRequestModel):
            return .requestCustomJSONEncodable(verifyPhoneRequestModel, encoder: JSONEncoder.default)
        case let .resendOtpForLogin(mobileNumber):
            return .requestParameters(
                parameters: ["mobile_number": mobileNumber],
                encoding: URLEncoding.queryString
            )
        }
    }
}
