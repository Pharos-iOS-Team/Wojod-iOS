// Copyright © 2026 Pharos Solutions. All rights reserved.

import Foundation

struct LessonHeaderModel {
    let section: Int
    let lessonName: String
    let lessonNumber: Int
    let isExpanded: Bool
    let isLocked: Bool
    let reservationState: CourseState?
    let doesContainAttachments: Bool
}

extension LessonHeaderModel {
    static func make(
        section: Int,
        lesson: Lesson,
        lessonNumber: Int,
        isExpanded: Bool,
        reservationState: CourseState?,
        doesContainAttachments: Bool
    ) -> LessonHeaderModel {
        return .init(
            section: section,
            lessonName: lesson.name,
            lessonNumber: lessonNumber,
            isExpanded: isExpanded,
            isLocked: lesson.locked,
            reservationState: reservationState,
            doesContainAttachments: doesContainAttachments
        )
    }
}
