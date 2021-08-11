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
    var id: Int?
    var batchID: Int?
    var subjectID: Int?
    var name: String?
    var batchName: String?
    var price: String?
    var media: Media?
    var video: Media?
    var summary: String?
    var rating: Double?
    var reviewsCount: Int?
    var reservationState: String?
    var receipt: Receipt?
}

struct Media: Codable {
    var fileName: String?
    var fileUrl: String?
    var thumbnailUrl: String?
    var contentType: String?
}

struct Receipt: Codable {
    var id: Int?
    var receiptNumber: String?
    var studentName: String?
    var teacherName: String?
    var courseName: String?
    var address: String?
    var reservationState: String?
}
