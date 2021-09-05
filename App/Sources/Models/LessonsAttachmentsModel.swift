// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

struct LessonAttachmentsModel: Codable {
    var quizzes: [Assessment]?
    var assignments: [Assessment]?
    var videos: [Video]?
    var documents: [MaterialsDocument]?
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
    var contentType: String?
    var type: String?
    var vdocipherId: String?
    var duration: Int?
    var link: String?
    var viewsRemaining: Int?
}

struct EncryptedVideoResponse: Codable {
    var otp: String?
    var playback: String?
    var updateId: Int?
}
