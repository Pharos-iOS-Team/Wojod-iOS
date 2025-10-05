// Copyright © 2020 Pharos Solutions. All rights reserved.

import FirebaseCore
import IQKeyboardManagerSwift
import IQKeyboardToolbarManager
import UIKit

class ThirdPartiesConfiguratorAppDelegate: AppDelegateType {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        configureIQKeyboard()
        configureFirebase()
        return true
    }

    private func configureIQKeyboard() {
        IQKeyboardManager.shared.isEnabled = true
        IQKeyboardManager.shared.resignOnTouchOutside = true
        IQKeyboardToolbarManager.shared.isEnabled = true
        IQKeyboardManager.shared.disabledDistanceHandlingClasses = [ChatViewController.self]
    }

    private func configureFirebase() {
        FirebaseApp.configure()
    }
}
