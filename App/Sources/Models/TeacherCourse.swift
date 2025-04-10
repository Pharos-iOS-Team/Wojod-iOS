// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

struct SubjectCourses: Codable {
    var teacher: Teacher?
    var courses: [Course]?
}

struct Teacher: Codable {
    var id: Int?
    var name: String?
    var initials: String?
}

struct CourseDetailsResponse: Codable {
    var course: Course?
}

struct Course: Codable {
    let id: Int
    let batchID: Int?
    let subjectID: Int?
    let name: String?
    let batchName: String?
    let price: String?
    let media: Media?
    let video: Media?
    let summary: String?
    let rating: Double?
    let reviewsCount: Int?
    let reservationState: String?
    let receipt: Receipt?
    let lessonsUnreadCount: Int?
    let materialsUnreadCount: Int?
    let qrCodeEnabled: Bool?
    let hideViews: Bool
}

struct Media: Codable {
    var fileName: String?
    var fileUrl: String?
    var thumbnailUrl: String?
    var contentType: String?
    var vdocipherId: String?
    var duration: Int?
    var link: String?
    var viewsRemaining: Int?
}

struct Receipt: Codable {
    var id: Int?
    var receiptNumber: String?
    var studentName: String?
    var teacherName: String?
    var courseName: String?
    var address: String?
    var reservationState: String?
    var price: String?
}
