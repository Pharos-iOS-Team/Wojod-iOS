// Copyright © 2021 Pharos Solutions. All rights reserved.

import LanguageManager_iOS
import UIKit

enum Language: String, CaseIterable {
    case english = "en"
    case arabic = "ar"

    static var `default`: Language {
        set(language) {
            LanguageManager.shared.defaultLanguage = Languages(rawValue: language.rawValue) ?? .en
        }
        get {
            return Language(rawValue: LanguageManager.shared.defaultLanguage.rawValue) ?? .english
        }
    }

    static var currentLanguage: Language {
        set(language) {
            guard let language = Languages(rawValue: language.rawValue) else { preconditionFailure("Language not supported") }
            LanguageManager.shared.setLanguage(language: language)
        }
        get {
            return Language(rawValue: LanguageManager.shared.currentLanguage.rawValue) ?? `default`
        }
    }

    static var semanticContent: UISemanticContentAttribute {
        switch currentLanguage {
        case .english:
            return .forceLeftToRight
        case .arabic:
            return .forceRightToLeft
        }
    }

    static var direction: UIUserInterfaceLayoutDirection {
        switch currentLanguage {
        case .english:
            return .leftToRight
        case .arabic:
            return .rightToLeft
        }
    }

    static var contentHorizontalAlignment: UIControl.ContentHorizontalAlignment {
        switch currentLanguage {
        case .english:
            return .left
        case .arabic:
            return .right
        }
    }

    static var textAlignment: NSTextAlignment {
        switch currentLanguage {
        case .english:
            return .left
        case .arabic:
            return .right
        }
    }

    static var locale: Locale {
        if let currentRegion = Locale.current.regionCode {
            return Locale(identifier: "\(Language.currentLanguage.rawValue)_\(currentRegion)@calendar=gregorian")
        }
        return Locale(identifier: Language.currentLanguage.rawValue)
    }

    var title: String {
        switch self {
        case .english:
            return "English"
        case .arabic:
            return "اللغة العربية"
        }
    }
}
