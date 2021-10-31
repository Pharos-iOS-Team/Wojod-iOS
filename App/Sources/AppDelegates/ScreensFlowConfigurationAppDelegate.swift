// Copyright © 2020 Pharos Solutions. All rights reserved.

import Foundation
import UIKit

class ScreensFlowConfigurationAppDelegate: AppDelegateType {
    static var shared = ScreensFlowConfigurationAppDelegate()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        navigateToMainScreen()
        return true
    }

    func navigateToMainScreen() {
        guard
            let appDelegate = UIApplication.shared.delegate as? AppDelegate,
            let window = appDelegate.window
        else {
            return
        }
        UIView.appearance().semanticContentAttribute = Language.semanticContent
        UINavigationBar.appearance().semanticContentAttribute = Language.semanticContent
        if let userToken = KeychainHandler.shared.userToken, !userToken.isEmpty {
            window.rootViewController = StoryboardScene.CoursesTabBar.coursesTabBarViewController.instantiate()
        } else {
            window.rootViewController = StoryboardScene.Login.loginViewController.instantiate()
        }
        UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {}) { _ in 
            window.isHidden = UIScreen.main.isCaptured
        }
        addScreenRecordingPreventionObserver()
    }

    private func addScreenRecordingPreventionObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(hideScreenIfBeingRecorded), name: UIScreen.capturedDidChangeNotification, object: nil)
    }

    @objc
    private func hideScreenIfBeingRecorded() {
        (UIApplication.shared.delegate as? AppDelegate)?.window?.isHidden = UIScreen.main.isCaptured
    }
}
