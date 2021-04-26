// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation
import Moya

enum CreatePasswordTarget {
    case createPassword(password: Password)
}

extension CreatePasswordTarget: TargetType {
    var path: String {
        return "/password"
    }

    var method: Moya.Method {
        return .put
    }

    var task: Task {
        switch self {
        case let .createPassword(password):
            return .requestCustomJSONEncodable(password, encoder: JSONEncoder.default)
        }
    }
}
