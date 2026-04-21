// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

class NotificationsViewModel {
    let model = NotificationsModel()

    func loadNotifications(completion: @escaping (Notifications) -> Void) {
        model.fetchNotifications { result in
            switch result {
            case .success(let notifications):
                completion(notifications)
            case .failure:
                break
            }
        }
    }
}
