// Copyright © 2021 Pharos Solutions GmbH. All rights reserved.

import Foundation

enum AssessmentStatus: String, CaseIterable {
    case open
    case closed
    
    static var statusRelevantToRole: AssessmentStatus {
        return .open
    }

    static func cases(assessments: [Assessment]) -> [AssessmentStatus] {
        let openCases = AssessmentStatus.allCases.filter { $0 == .open }
        let closedCases = AssessmentStatus.allCases.filter { $0 == .closed }
        if !assessments.contains(where: { $0.status == "open" }) {
            return closedCases
        } else if !assessments.contains(where: { $0.status == "closed" }) {
            return openCases
        } else {
            return AssessmentStatus.allCases
        }
    }
}
