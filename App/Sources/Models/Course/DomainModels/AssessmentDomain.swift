// Copyright © 2026 Pharos Solutions. All rights reserved.

import UIKit

struct AssessmentDomain {
    let id: Int?
    let title: String?
    let publishedAt: Date
    let type: AssessmentType
    let status: AssessmentStatus
}

// MARK: - MaterialItemProtocol
extension AssessmentDomain: MaterialItemProtocol {
    var displayTitle: String? { title }
    var displayDate: String { publishedAt.formattedDateString }
    var displayIcon: UIImage { Images.quiz.image }
    var displayDuration: Int? { nil }
    var displayDaysRemaining: Int? { nil }
    var payload: MaterialItemPayload { .assessment(self) }
}
