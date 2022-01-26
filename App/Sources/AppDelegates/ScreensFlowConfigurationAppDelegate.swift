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
        UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: nil) { _ in
            self.hideScreenIfBeingRecorded()
        }
        addScreenRecordingPreventionObserver()
        preventScreenshot()
    }

    private func addScreenRecordingPreventionObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(hideScreenIfBeingRecorded), name: UIScreen.capturedDidChangeNotification, object: nil)
    }

    func preventScreenshot() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.userDidTakeScreenshotNotification,
            object: nil,
            queue: OperationQueue.main
        ) { notification in
            self.handleSendingScreenshotAlert()
        }
    }

    @objc
    private func hideScreenIfBeingRecorded() {
        guard let viewController = (UIApplication.shared.delegate as? AppDelegate)?.window?.visibleViewController else { return }
        guard UIScreen.main.isCaptured else { return }
        if ReachabilityAppDelegate.connectionState == .connected {
            User.shared.screenshotAlert(screenName: String(describing: viewController.title ?? ""), isRecording: true)
        }
        handleCrashingTheAppForRecording()
    }

    private func handleSendingScreenshotAlert() {
        guard let viewController = (UIApplication.shared.delegate as? AppDelegate)?.window?.visibleViewController else { return }
        if ReachabilityAppDelegate.connectionState == .connected {
            User.shared.screenshotAlert(screenName: String(describing: viewController.title ?? ""), isRecording: false)
        }
        handleCrashingTheAppForTakingScreenshot()
    }

    private func handleCrashingTheAppForTakingScreenshot() {
        (UIApplication.shared.delegate as? AppDelegate)?.window?.visibleViewController?.showAlert(
            imageName: Images.danger.name,
            title: L10n.Shared.Alerts.screenshotsNotAllowed,
            message: L10n.Shared.Alerts.appWillTerminate
        ) {
            exit(-1)
        }
        _ = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
            exit(-1)
        }
    }

    private func handleCrashingTheAppForRecording() {
        guard let viewController = (UIApplication.shared.delegate as? AppDelegate)?.window?.visibleViewController else { return }
        viewController.view.isHidden = true
        viewController.showAlert(
            imageName: Images.danger.name,
            title: L10n.Shared.Alerts.screenRecordingNotAllowed,
            message: L10n.Shared.Alerts.appWillTerminate
        ) {
            exit(-1)
        }
        _ = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
            exit(-1)
        }
    }
}
