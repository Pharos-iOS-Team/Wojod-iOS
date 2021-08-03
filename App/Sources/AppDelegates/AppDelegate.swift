// Copyright © 2021 Pharos Solutions. All rights reserved.

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
}
