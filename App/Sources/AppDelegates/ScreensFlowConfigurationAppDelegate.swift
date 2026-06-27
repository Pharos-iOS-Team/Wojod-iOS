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
            let loginVC = StoryboardScene.Login.loginViewController.instantiate()
            let navController = UINavigationController(rootViewController: loginVC)
            navController.setNavigationBarHidden(true, animated: false)
            window.rootViewController = navController
        }
        addAirPlayPreventionObserver()
    }

    private func addAirPlayPreventionObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(hideScreenIfBeingAirPlayed(_:)),
            name: AVAudioSession.routeChangeNotification,
            object: nil
        )
    }

    @objc
    private func hideScreenIfBeingAirPlayed(_ notification: NSNotification?) {
        guard isAirplayOn() else { return }
        handleCrashingTheAppForAirPlay()
    }

    private func isAirplayOn() -> Bool {
        let audioSession = AVAudioSession.sharedInstance()
        let currentRoute = audioSession.currentRoute
        for outputPort in currentRoute.outputs where outputPort.portType == AVAudioSession.Port.airPlay {
            return true
        }
        return false
    }

    private func handleCrashingTheAppForAirPlay() {
        guard let viewCtrl = (UIApplication.shared.delegate as? AppDelegate)?.window?.visibleViewController else { return }
        viewCtrl.view.isHidden = true
        viewCtrl.showAlert(
            imageName: Images.danger.name,
            title: L10n.Shared.Alerts.airPlayingNotAllowed,
            message: L10n.Shared.Alerts.appWillTerminate
        ) {
            exit(-1)
        }
        _ = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
            exit(-1)
        }
    }
}
