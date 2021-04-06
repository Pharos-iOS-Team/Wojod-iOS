// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit

typealias AppDelegateType = UIResponder & UIApplicationDelegate

@UIApplicationMain
class AppDelegate: AppDelegateType {
    var window: UIWindow?
    var appDelegateComposer = AppDelegateFactory.makeDefault()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        _ = appDelegateComposer.application(application, didFinishLaunchingWithOptions: launchOptions)
        return true
    }
}
