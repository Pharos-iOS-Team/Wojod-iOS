// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

struct LessonAttachmentsModel: Codable {
    var quizzes: [Quiz]?
    var assignments: [Assignment]?
    var videos: [Video]?
    var documents: [Document]?
}

struct Quiz: Codable {
    var id: Int
    var title: String?
    var instructions: String?
    var duration: Int?
    var numberOfQuestions: Int?
    var mark: Int?
    var publishedAt: String?
    var type: String?
}

struct Assignment: Codable {
    var id: Int
    var title: String?
    var instructions: String?
    var duration: Int?
    var numberOfQuestions: Int?
    var publishedAt: String?
    var type: String?
}

struct Video: Codable {
    var id: Int
    var title: String?
    var fileUrl: String?
    var fileName: String?
    var contentType: Int?
    var type: String?
}

struct Document: Codable {
    var id: Int
    var title: String?
    var link: String?
    var fileUrl: String?
    var fileName: String?
    var contentType: Int?
    var type: String?
}
