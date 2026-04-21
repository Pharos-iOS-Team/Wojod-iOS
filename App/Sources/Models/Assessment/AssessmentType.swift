// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation
import UIKit

enum AssessmentType: String {
    case quiz = "Quiz"
    case assignment

    var title: String {
        switch self {
        case .quiz:
            return L10n.Home.quiz
        case .assignment:
            return L10n.Home.excersise
        }
    }

    var icon: UIImage {
        switch self {
        case .quiz:
            return Images.homeAssesmentsIcn.image
        default:
            return Images.homeExcersiseIcon.image
        }
    }
}
