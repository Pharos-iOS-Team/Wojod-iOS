// Copyright © 2020 Pharos Solutions. All rights reserved.

import FirebaseCore
import IQKeyboardManagerSwift
import UIKit

class ThirdPartiesConfiguratorAppDelegate: AppDelegateType {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        configureIQKeyboard()
        configureFirebase()
        return true
    }

    private func configureIQKeyboard() {
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        IQKeyboardManager.shared.toolbarDoneBarButtonItemText = L10n.Global.Actions.done
        IQKeyboardManager.shared.disabledDistanceHandlingClasses = [ChatViewController.self]
    }

    private func configureFirebase() {
        FirebaseApp.configure()
    }
}
