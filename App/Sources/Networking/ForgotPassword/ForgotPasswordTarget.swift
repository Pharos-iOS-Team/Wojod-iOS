// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation
import Moya

enum ForgotPasswordTarget {
    case sendMobileNumber(GetOTPRequestModel)
    case verifyOtp(otp: OtpVerification)
    case verifyOtpFromLogin(otp: OtpVerification)
}

extension ForgotPasswordTarget: TargetType {
    var path: String {
        switch self {
        case .sendMobileNumber:
            return "/password/send_otp"
        case .verifyOtp:
            return "/password/verify_otp"
        case .verifyOtpFromLogin:
            return "/verify_otp"
        }
    }

    var method: Moya.Method {
        return .post
    }

    var task: Task {
        switch self {
        case let .sendMobileNumber(otp):
            return .requestCustomJSONEncodable(otp, encoder: JSONEncoder.default)
        case let .verifyOtp(otp):
            return .requestCustomJSONEncodable(otp, encoder: JSONEncoder.default)
        case let .verifyOtpFromLogin(otp):
            return .requestCustomJSONEncodable(otp, encoder: JSONEncoder.default)
        }
    }
}
