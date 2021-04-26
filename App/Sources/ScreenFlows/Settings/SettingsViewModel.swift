// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit

enum Settings: Int, CaseIterable {
    case version
    case privacyPolicy
    case termsOfService
    case languages
}

struct SettingsCellModel {
    var image: UIImage?
    var title: String?
    var versionNumber: String?
}

class SettingsViewModel {
    private func getSettingsImage(forSettings settings: Int) -> UIImage {
        switch settings {
        case Settings.version.rawValue:
            return Images.setting.image
        case Settings.privacyPolicy.rawValue:
            return Images.privacy.image
        case Settings.termsOfService.rawValue:
            return Images.alert.image
        case Settings.languages.rawValue:
            return Images.gear.image
        default:
            return UIImage()
        }
    }

    private func getSettingsTitle(forSettings settings: Int) -> String {
        switch settings {
        case Settings.version.rawValue:
            return L10n.Settings.version
        case Settings.privacyPolicy.rawValue:
            return L10n.Settings.privacyPolicy
        case Settings.termsOfService.rawValue:
            return L10n.Settings.termsOfService
        case Settings.languages.rawValue:
            return L10n.Settings.languages
        default:
            return ""
        }
    }

    private func getVersionNumber(forSettings settings: Int) -> String? {
        guard settings != .zero else { return "2.1.2.001" }
        return nil
    }

    func getCellModel(forSettings settings: Int) -> SettingsCellModel {
        return SettingsCellModel(
            image: getSettingsImage(forSettings: settings),
            title: getSettingsTitle(forSettings: settings),
            versionNumber: getVersionNumber(forSettings: settings)
        )
    }

    func getUrl(forIndex index: Int) -> URL? {
        switch index {
        case Settings.privacyPolicy.rawValue:
            return URL(string: "http://courses.pharos-solutions.de/privacy_policy")
        case Settings.termsOfService.rawValue:
            return URL(string: "http://courses.pharos-solutions.de/terms_services")
        default:
            return URL(string: "")
        }
    }
}
