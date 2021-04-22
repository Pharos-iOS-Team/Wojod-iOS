// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation
import Moya

enum ProfileTarget {
    case getProfile(id: String)
    case editProfile(id: String, profile: Profile)
}

extension ProfileTarget: TargetType {
    var path: String {
        switch self {
        case .getProfile(let id):
            return "/students/\(id)"

        case .editProfile(let id, _):
            return "/students/\(id)"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getProfile:
            return .get
        case .editProfile:
            return .put
        }
    }

    var task: Task {
        switch self {
        case let .getProfile(id):
            return .requestParameters(parameters: ["id": id], encoding: URLEncoding.default)
        case let .editProfile(_, profile):
            return .requestCustomJSONEncodable(profile, encoder: JSONEncoder.default)
        }
    }
}
