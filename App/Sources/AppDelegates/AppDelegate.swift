// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit
import UserNotifications

typealias AppDelegateType = UIResponder & UIApplicationDelegate

@UIApplicationMain
class AppDelegate: AppDelegateType {
    static func getAppDelegate() -> AppDelegate! {
        return UIApplication.shared.delegate as? AppDelegate
    }

    var window: UIWindow?
    var appDelegateComposer = AppDelegateFactory.makeDefault()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        _ = appDelegateComposer.application(application, didFinishLaunchingWithOptions: launchOptions)
        registerForPushNotifications()
        return true
    }

    func registerForPushNotifications() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                print("Permission granted: \(granted)")
                guard granted else { return }
                self.getNotificationSettings()
            }
    }

    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("Failed to register: \(error)")
    }
}
