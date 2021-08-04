// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation
import Moya

enum NotificationsTarget {
    case getNotifications
    case markAsRead(id: String)
    case registerDeviceToken(tokenModel: DeviceToken)
    case readAllNotifications
}

extension NotificationsTarget: TargetType {
    var path: String {
        switch self {
        case .getNotifications:
            return "/notifications"
        case .markAsRead(let id):
            return "/notifications/\(id)"
        case .registerDeviceToken:
            return "/device_token"
        case .readAllNotifications:
            return "/notifications/mark_all_as_read"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getNotifications:
            return .get
        case .markAsRead, .readAllNotifications, .registerDeviceToken:
            return .put
        }
    }

    var task: Task {
        switch self {
        case .getNotifications:
            return .requestPlain
        case .markAsRead, .readAllNotifications:
            return .requestPlain
        case let .registerDeviceToken(tokenModel: tokenModel):
            return .requestCustomJSONEncodable(tokenModel, encoder: encoder)
        }
    }
}
