// Copyright © 2021 Pharos Solutions. All rights reserved.

import CoreData
import FirebaseCore
import FirebaseMessaging
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
        return true
    }

    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if application.applicationState == .background && ReachabilityAppDelegate.connectionState == .connected {
            AssessmentSynchronization().startSynchronization()
        }
        completionHandler(.noData)
    }
}
