// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation
import Moya

enum ForgotPasswordTarget {
    case sendMobileNumber(mobileNumber: String)
}

extension ForgotPasswordTarget: TargetType {
    var path: String {
        return "/auth/sign_in"
    }

    var method: Moya.Method {
        return .post
    }

    var task: Task {
        switch self {
        case let .sendMobileNumber(mobileNumber):
            return .requestCustomJSONEncodable(mobileNumber, encoder: JSONEncoder.default)
        }
    }
}
