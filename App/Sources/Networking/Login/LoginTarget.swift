// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation
import Moya

enum LoginTarget {
    case login(loginRequestModel: LoginRequestModel)
}

extension LoginTarget: TargetType {
    var path: String {
        return "/auth/sign_in"
    }

    var method: Moya.Method {
        return .post
    }

    var task: Task {
        switch self {
        case let .login(loginRequestModel):
            return .requestCustomJSONEncodable(loginRequestModel, encoder: JSONEncoder.default)
        }
    }
}
