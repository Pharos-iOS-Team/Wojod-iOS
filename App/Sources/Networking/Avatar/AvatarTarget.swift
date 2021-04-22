// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation
import Moya

enum AvatarTarget {
    case getAvatars
}

extension AvatarTarget: TargetType {
    var path: String {
        return "/avatars"
    }

    var method: Moya.Method {
        return .get
    }

    var task: Task {
        switch self {
        case .getAvatars:
            return .requestPlain
        }
    }
}
