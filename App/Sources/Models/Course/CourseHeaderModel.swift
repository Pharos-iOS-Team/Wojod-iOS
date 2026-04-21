// Copyright © 2026 Pharos Solutions. All rights reserved.

import Foundation

struct CourseHeaderModel {
    var courseTitle: String?
    var teacherName: String?
    var batchName: String?
    var image: String?
    var video: Media?
    var description: String?
    var price: String?
    var numberOfReviews: String?
    var rating: Double?
    var shouldHideMaterials: Bool
    var buttonSelected: ActiveScreen
    var state: CourseState
    var lessonsUnreadCount: Int?
    var materialsUnreadCount: Int?
}

extension CourseHeaderModel {
    static func make(
        course: Course?,
        teacherName: String?,
        activeScreen: ActiveScreen,
    ) -> CourseHeaderModel {
        return .init(
            courseTitle: course?.name,
            teacherName: teacherName,
            batchName: course?.batchName,
            image: course?.media?.fileUrl,
            video: course?.video,
            description: course?.summary,
            price: course?.price,
            numberOfReviews: String(course?.reviewsCount ?? .zero),
            rating: course?.rating,
            shouldHideMaterials: course?.parsedState != .booked,
            buttonSelected: activeScreen,
            state: course?.parsedState ?? .normal,
            lessonsUnreadCount: course?.lessonsUnreadCount,
            materialsUnreadCount: course?.materialsUnreadCount
        )
    }
}
