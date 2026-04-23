// Copyright © 2026 Pharos Solutions. All rights reserved.

import Siren
import UIKit

class ForceUpdateAppDelegate: AppDelegateType {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        showAppUpdateAlert()
        return true
    }

    private func showAppUpdateAlert() {
        let siren = Siren.shared
        siren.rulesManager = RulesManager(globalRules: .critical)
        siren.presentationManager = .init(forceLanguageLocalization: Localization.Language(rawValue: Language.currentLanguage.rawValue))
        siren.wail(performCheck: .onForeground)
    }
}
