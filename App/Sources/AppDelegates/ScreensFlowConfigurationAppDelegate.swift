// Copyright © 2020 Pharos Solutions. All rights reserved.

import AVFAudio
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
    }

    private func addScreenRecordingPreventionObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(hideScreenIfBeingRecorded),
            name: UIScreen.capturedDidChangeNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(hideScreenIfBeingAirPlayed(_:)),
            name: AVAudioSession.routeChangeNotification,
            object: nil
        )
    }

    @objc
    private func hideScreenIfBeingRecorded() {
        guard let viewCtrl = (UIApplication.shared.delegate as? AppDelegate)?.window?.visibleViewController else { return }
        guard UIScreen.main.isCaptured else { return }
        if ReachabilityAppDelegate.connectionState == .connected {
            User.shared.screenshotAlert(screenName: String(describing: viewCtrl.title ?? ""), isRecording: true)
        }
        handleCrashingTheAppForRecording()
    }

    @objc
    private func hideScreenIfBeingAirPlayed(_ notification: NSNotification?) {
        guard let viewCtrl = (UIApplication.shared.delegate as? AppDelegate)?.window?.visibleViewController else { return }

        guard isAirplayOn() else { return }
        if ReachabilityAppDelegate.connectionState == .connected {
            User.shared.screenshotAlert(screenName: String(describing: viewCtrl.title ?? ""), isRecording: true)
        }
        handleCrashingTheAppForRecording()
    }

    private func isAirplayOn() -> Bool {
        let audioSession = AVAudioSession.sharedInstance()
        let currentRoute = audioSession.currentRoute
        for outputPort in currentRoute.outputs where outputPort.portType == AVAudioSession.Port.airPlay {
            return true
        }
        return false
    }

    private func handleCrashingTheAppForRecording() {
        guard let viewCtrl = (UIApplication.shared.delegate as? AppDelegate)?.window?.visibleViewController else { return }
        viewCtrl.view.isHidden = true
        viewCtrl.showAlert(
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
