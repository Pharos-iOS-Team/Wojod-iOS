// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation
import Moya

enum SetPasswordTarget {
    case setPassword(request: SetPasswordRequest)
}

extension SetPasswordTarget: TargetType {
    var path: String {
        return "/auth/set_password"
    }

    var method: Moya.Method {
        return .post
    }

    var task: Task {
        switch self {
        case let .setPassword(request):
            return .requestCustomJSONEncodable(request, encoder: JSONEncoder.default)
        }
    }
}
