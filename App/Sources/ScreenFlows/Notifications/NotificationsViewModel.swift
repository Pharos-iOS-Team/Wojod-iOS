// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

class NotificationsViewModel {
    let model = NotificationsModel()

    func loadNotifications(completion: @escaping ([Notification]) -> Void) {
        model.loadNotifications { notifications in
            completion(notifications)
        }
    }
}
