// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation
import Moya

enum ForgotPasswordTarget {
    case sendMobileNumber(mobileNumber: String)
    case verifyOtp(otp: OtpVerification)
}

extension ForgotPasswordTarget: TargetType {
    var path: String {
        switch self {
        case .sendMobileNumber:
            return "/password/send_otp"
        case .verifyOtp:
            return "/password/verify_otp"
        }
    }

    var method: Moya.Method {
        return .post
    }

    var task: Task {
        switch self {
        case let .sendMobileNumber(mobileNumber):
            return .requestParameters(parameters: ["mobile_number": mobileNumber], encoding: URLEncoding.queryString)
        case let .verifyOtp(otp):
            return .requestCustomJSONEncodable(otp, encoder: JSONEncoder.default)
        }
    }
}
