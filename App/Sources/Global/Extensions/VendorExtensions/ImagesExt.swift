// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit

typealias Images = Asset.Images
typealias Colors = Asset.Colors

extension Images {
    static var localizedBackButton: UIImage {
        switch Language.currentLanguage {
        case .english:
            return backIcon.image
        case .arabic:
            return backIcon.image.withHorizontallyFlippedOrientation()
        }
    }
    static var localizedDisclosureIndicatorButton: UIImage {
        switch Language.currentLanguage {
        case .english:
            return disclosureIndicator.image
        case .arabic:
            return disclosureIndicator.image.withHorizontallyFlippedOrientation()
        }
    }
}

extension Images {
    static var signUpTitlePageOne: UIImage {
        switch Language.currentLanguage {
        case .english:
            return signUpTitlePageOneEn.image
        case .arabic:
            return signUpTitlePageOneAr.image
        }
    }
}
