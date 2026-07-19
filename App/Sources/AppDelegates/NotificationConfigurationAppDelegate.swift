// Copyright © 2020 Pharos Solutions. All rights reserved.

import FirebaseMessaging
import SwiftyUserDefaults
import UIKit
import UserNotifications

class NotificationConfigurationAppDelegate: AppDelegateType {
    private let gcmMessageIDKey: String = "gcm.message_id"
    private let notificationCenter = UNUserNotificationCenter.current()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        registerForPushNotifications()
        return true
    }

    func registerForPushNotifications() {
        Messaging.messaging().delegate = self
        notificationCenter.delegate = self
        notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { [weak self] granted, error in
            if let error = error {
                analytics.log(error: error.localizedDescription)
            }
            guard granted else { return }
            self?.fetchNotificationSettings()
        }
    }

    func fetchNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        PushNotificationsManager.shared.sendUserDeviceToken(Messaging.messaging().fcmToken)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        analytics.log(error: "Push Notifications registeration failed: \(error.localizedDescription)")
    }

    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        completionHandler(UIBackgroundFetchResult.newData)
    }
}

extension NotificationConfigurationAppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        Defaults[\.fcmToken] = fcmToken
        PushNotificationsManager.shared.sendUserDeviceToken(fcmToken)
    }
}

extension NotificationConfigurationAppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.alert, .sound, .badge])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        guard let userinfo = response.notification.request.content.userInfo as? [String: Any] else {
            completionHandler()
            return
        }
        if let notificationType = userinfo["entity_name"] as? String, notificationType == "Notifications" {
            let viewCtrl = StoryboardScene.Notifications.initialScene.instantiate()
            UIApplication.shared.keyWindow?.rootViewController?.present(viewCtrl, animated: true)
            completionHandler()
        } else if let courseID = userinfo["course_id"] as? String {
            Task {
                let courseResponse = try? await CourseDetailsRepository().loadCourse(courseID: courseID)
                await MainActor.run {
                    guard let course = courseResponse?.course else {
                        completionHandler()
                        return
                    }
                    let viewModel = CourseDetailsViewModel().with {
                        $0.state.course = course
                    }
                    let viewCtrl = CourseDetailsViewController.make(viewModel: viewModel, coordinator: CourseDetailsCoordinator())
                    let navigationCtrl = UINavigationController(rootViewController: viewCtrl)
                    navigationCtrl.modalPresentationStyle = .fullScreen
                    UIApplication.shared.keyWindow?.rootViewController?.present(navigationCtrl, animated: true)
                    completionHandler()
                }
            }
        } else {
            completionHandler()
        }
    }
}
