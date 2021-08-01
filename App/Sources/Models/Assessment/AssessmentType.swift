// Copyright © 2021 Pharos Solutions GmbH. All rights reserved.

import Foundation
import UIKit

enum AssessmentType: String {
    case quiz
    case assignment

    var title: String {
        switch self {
        case .quiz:
            return "home.quiz".localiz()
        case .assignment:
            return "home.excersise".localiz()
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
