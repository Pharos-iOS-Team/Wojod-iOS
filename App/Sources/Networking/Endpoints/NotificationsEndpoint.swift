// Copyright © 2026 Pharos Solutions. All rights reserved.

import Foundation
import Moya

enum NotificationsEndpoint {
    case getNotifications
    case markAsRead(IDRequestModel)
    case registerDeviceToken(DeviceToken)
    case readAllNotifications
}

extension NotificationsEndpoint: TargetType {
    var path: String {
        switch self {
        case .getNotifications:
            return "/notifications"
        case let .markAsRead(requestModel):
            return "/notifications/\(requestModel.id)"
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
        case let .registerDeviceToken(tokenModel):
            return .requestCustomJSONEncodable(tokenModel, encoder: .default)
        default:
            return .requestPlain
        }
    }
}
