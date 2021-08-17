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

    static var localizedWhiteBackButton: UIImage {
        switch Language.currentLanguage {
        case .english:
            return backIconWhite.image
        case .arabic:
            return backIconWhite.image.withHorizontallyFlippedOrientation()
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

    static var localizedNextButton: UIImage {
        switch Language.currentLanguage {
        case .english:
            return nextIcon.image
        case .arabic:
            return nextIcon.image.withHorizontallyFlippedOrientation()
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

    static var locationInfoTitle: UIImage {
        switch Language.currentLanguage {
        case .english:
            return locationInfoTitleEn.image
        case .arabic:
            return locationInfoTitleAr.image
        }
    }

    static var academicInfoTitle: UIImage {
        switch Language.currentLanguage {
        case .english:
            return academicInfoTitleEn.image
        case .arabic:
            return academicInfoTitleAr.image
        }
    }

    static var letsKnowMoreTitle: UIImage {
        switch Language.currentLanguage {
        case .english:
            return letsKnowMoreTitleEn.image
        case .arabic:
            return letsKnowMoreTitleAr.image
        }
    }

    static var addAvatarTitle: UIImage {
        switch Language.currentLanguage {
        case .english:
            return addAvatarTitleEn.image
        case .arabic:
            return addAvatarTitleAr.image
        }
    }

    static var wrongCredentials: UIImage {
        switch Language.currentLanguage {
        case .english:
            return wrongCredentialsEn.image
        case .arabic:
            return wrongCredentialsAr.image
        }
    }

    static var firstMilestone: UIImage {
        switch Language.currentLanguage {
        case .english:
            return firstMilestoneEn.image
        case .arabic:
            return firstMilestoneAr.image
        }
    }

    static var secondMilestone: UIImage {
        switch Language.currentLanguage {
        case .english:
            return secondMilestoneEn.image
        case .arabic:
            return secondMilestoneAr.image
        }
    }

    static var thirdMilestone: UIImage {
        switch Language.currentLanguage {
        case .english:
            return thirdMilestoneEn.image
        case .arabic:
            return thirdMilestoneAr.image
        }
    }

    static var fourthMilestone: UIImage {
        switch Language.currentLanguage {
        case .english:
            return fourthMilestoneEn.image
        case .arabic:
            return fourthMilestoneAr.image
        }
    }
}
