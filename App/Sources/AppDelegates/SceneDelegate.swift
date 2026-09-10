// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        AppDelegate.getAppDelegate()?.window = window
        window.makeKeyAndVisible()
        ScreensFlowConfigurationAppDelegate.shared.navigateToMainScreen()
    }
}
