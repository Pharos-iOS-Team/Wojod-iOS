// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation
import Moya

enum UserProfileTarget {
    case getUserProfile(id: Int)
}

extension UserProfileTarget: TargetType {
    var path: String {
        switch self {
        case .getUserProfile(let id):
            return "/students/\(id)"
        }
    }

    var method: Moya.Method {
        return .get
    }

    var task: Task {
        switch self {
        case let .getUserProfile(id):
            return .requestParameters(parameters: ["id": id], encoding: URLEncoding.default)
        }
    }
}
