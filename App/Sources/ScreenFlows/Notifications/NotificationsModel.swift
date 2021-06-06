// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

class NotificationsModel {
    func loadNotifications(completion: @escaping ([Notification]) -> Void) {
        var notifications: [Notification] = []
        let firstNotification = Notification(teacherName: "Malak", timeStamp: "12 mins", message: "Sent a new message")
        let secondNotification = Notification(teacherName: "Nada", timeStamp: "23 Feb", message: "Shared a file")
        let thirdNotification = Notification(teacherName: "Mona", timeStamp: "12 Mar", message: "Published a new course")
        notifications.append(firstNotification)
        notifications.append(secondNotification)
        notifications.append(thirdNotification)

        completion(notifications)
    }
}
