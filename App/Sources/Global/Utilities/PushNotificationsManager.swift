// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

final class PushNotificationsManager {
    static let shared = PushNotificationsManager()
    let apiClient = NotificationsApiClient()

    private init() {}

    func sendUserDeviceToken(_ tokenData: String?) {
        guard let tokenData = tokenData, !tokenData.isEmpty else { return }
        let deviceToken = DeviceToken(deviceTokenNew: tokenData)
        apiClient.registerDeviceToken(deviceToken: deviceToken)
    }
}
