// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation
import Moya

enum LoginTarget {
    case login(loginRequestModel: LoginRequestModel)
    case guestMode
}

extension LoginTarget: TargetType {
    var path: String {
        switch self {
        case .login:
            return "/auth/sign_in"
        case .guestMode:
            return "/white_label_version"
        }
    }

    var method: Moya.Method {
        switch self {
        case .login:
            return .post
        case .guestMode:
            return .get
        }
    }

    var task: Task {
        switch self {
        case let .login(loginRequestModel):
            return .requestCustomJSONEncodable(loginRequestModel, encoder: JSONEncoder.default)
        case .guestMode:
            return .requestPlain
        }
    }
}
