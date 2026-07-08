// Copyright © 2021 Pharos Solutions. All rights reserved.

import Dependencies
import Foundation

class NotificationsViewModel {
    @Dependency(\.apiProvider)
    var apiProvider: ApiProvider

    func loadNotifications(completion: @escaping ([NotificationDataModel]) -> Void) {
        apiProvider.request(.notifications(.getNotifications), decodeTo: ApiResponse<[NotificationDataModel]>.self) { result in
            switch result {
            case .success(let notifications):
                completion(notifications.data)
            case .failure:
                return
            }
        }
    }
}
