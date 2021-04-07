// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation
import Moya

class NotificationsApiClient {
    let notificationsProvider = MoyaProvider<NotificationsTarget>()

    func fetchNotifications(page: String, completionHandler: @escaping (Response?, String?) -> Void) {
        notificationsProvider.request(.getNotifications(page: page)) { result in
            switch result {
            case .success(let response):
                completionHandler(response, nil)
            case .failure:
                completionHandler(nil, "")
            }
        }
    }

    func readAllNotifications(completionHandler: @escaping (Response?, String?) -> Void) {
        notificationsProvider.request(.readAllNotifications) { result in
            switch result {
            case .success(let response):
                completionHandler(response, nil)
            case .failure:
                completionHandler(nil, "")
            }
        }
    }

    func markAsRead(id: String) {
        notificationsProvider.request(.markAsRead(id: id)) { _ in }
    }

    func registerDeviceToken(deviceToken: DeviceToken) {
        notificationsProvider.request(.registerDeviceToken(tokenModel: deviceToken)) { _ in }
    }
}
