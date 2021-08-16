// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation
import Moya

enum LogoutTarget {
    case logout(deviceId: String)
}

extension LogoutTarget: TargetType {
    var path: String {
        return "/auth/sign_out"
    }

    var method: Moya.Method {
        return .delete
    }

    var headers: [String: String]? {
        return [
            "access-token": User.shared.getAccessToken(),
            "client": User.shared.client ?? "",
            "uid": User.shared.uid ?? ""
        ]
    }

    var task: Task {
        switch self {
        case .logout(let deviceId):
            return .requestCustomJSONEncodable(deviceId, encoder: JSONEncoder.default)
        }
    }
}
