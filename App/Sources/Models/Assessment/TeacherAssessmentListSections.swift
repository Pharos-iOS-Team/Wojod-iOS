// Copyright © 2021 Pharos Solutions GmbH. All rights reserved.

import Foundation

enum TeacherAssessmentListSections: String, CaseIterable {
    case latest
    case earlier
    
    var title: String {
        switch self {
        case .latest:
            return "files.latest".localiz()
        case .earlier:
            return "homework.earlier".localiz()
        }
    }
}
