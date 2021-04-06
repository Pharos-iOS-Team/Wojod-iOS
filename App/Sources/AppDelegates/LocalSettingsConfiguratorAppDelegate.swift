// Copyright © 2020 Pharos Solutions. All rights reserved.

import SwiftyUserDefaults
import UIKit

class LocalSettingsConfiguratorAppDelegate: AppDelegateType {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        configureParameterOnFreshInstall(application)
        Language.default = .english
        return true
    }

    private func configureParameterOnFreshInstall(_ application: UIApplication) {
        if Defaults[\.isFreshInstall] {
            KeychainHandler.shared.deleteUserToken()
            Defaults[\.isFreshInstall] = false
            application.applicationIconBadgeNumber = 0
        }
    }
}
