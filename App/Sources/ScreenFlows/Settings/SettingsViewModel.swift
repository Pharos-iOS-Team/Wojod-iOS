// Copyright © 2021 Pharos Solutions. All rights reserved.

import SwiftyUserDefaults
import UIKit

enum Settings: Int, CaseIterable {
    case version
    case privacyPolicy
    case languages
    case organizations

    func getSettingsImage(forSettings settings: Int) -> UIImage {
        switch settings {
        case Settings.version.rawValue:
            return Images.setting.image
        case Settings.privacyPolicy.rawValue:
            return Images.privacy.image
        case Settings.languages.rawValue:
            return Images.gear.image
        case Settings.organizations.rawValue:
            return Images.organizationsSettings.image
        default:
            return UIImage()
        }
    }

    func getSettingsTitle(forSettings settings: Int) -> String {
        switch settings {
        case Settings.version.rawValue:
            return L10n.Settings.version
        case Settings.privacyPolicy.rawValue:
            return L10n.Settings.privacyPolicy
        case Settings.languages.rawValue:
            return L10n.Settings.languages
        case Settings.organizations.rawValue:
            return L10n.Organizations.title
        default:
            return ""
        }
    }
}

struct SettingsCellModel {
    var image: UIImage?
    var title: String?
    var versionNumber: String?
}

class SettingsViewModel {
    var availableSettings: [Settings] {
        var allSettings = Settings.allCases
        if isGuestModeEnabled() {
            allSettings.removeAll { $0 == .organizations }
        }
        return allSettings
    }

    private func getVersionNumber(forSettings settings: Int) -> String? {
        guard settings != .zero else { return GlobalConstants.Application.version }
        return nil
    }

    func getCellModel(forSettings settings: Int) -> SettingsCellModel {
        return SettingsCellModel(
            image: Settings(rawValue: settings)?.getSettingsImage(forSettings: settings),
            title: Settings(rawValue: settings)?.getSettingsTitle(forSettings: settings),
            versionNumber: getVersionNumber(forSettings: settings)
        )
    }

    func getUrl(forIndex index: Int) -> URL? {
        switch index {
        case Settings.privacyPolicy.rawValue:
            return URL(string: "\(Environment.baseURLString)/privacy_policy")
        default:
            return URL(string: "")
        }
    }

    func getUserAvatar(avatarLink: String) -> URL? {
        return Environment.baseURL.appendingPathComponent(avatarLink)
    }

    func isGuestModeEnabled() -> Bool {
        return Defaults[\.isGuestModeEnabled]
    }

    func logout() {
        User.shared.setLoggedOut()
        ScreensFlowConfigurationAppDelegate.shared.navigateToMainScreen()
    }
}
