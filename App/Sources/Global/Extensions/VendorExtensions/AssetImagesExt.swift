// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit

typealias Images = Asset.Images

extension Images {
    static var localizedBackButton: UIImage {
        switch Language.currentLanguage {
        case .english:
            return backIcon.image
        case .arabic:
            return backIcon.image.withHorizontallyFlippedOrientation()
        }
    }
}

//extension Images {
//    static var freelancerOnboardingHeader: UIImage {
//        switch Language.currentLanguage {
//        case .english:
//            return freelancerOnboardingHeaderEn.image
//        case .arabic:
//            return freelancerOnboardingHeaderAr.image
//        }
//    }
//}
