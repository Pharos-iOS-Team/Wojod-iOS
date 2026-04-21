// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

class NotificationsModel {
    func fetchNotifications(completion: @escaping (Swift.Result<Notifications, Error>) -> Void) {
        ApiProvider.shared.request(.notifications(.getNotifications), decodeTo: Notifications.self, completion: completion)
    }
}
