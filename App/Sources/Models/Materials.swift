// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

struct Materials: Codable {
    var quizzes: [Assessment]?
    var assignments: [Assessment]?
    var videos: [MaterialsVideo]?
    var documents: [MaterialsDocument]?
}

//struct MaterialsQuiz: Codable {
//    var id: Int?
//    var title: String?
//    var instructions: String?
//    var duration: Int?
//    var numberOfQuestions: Int?
//    var mark: Int?
//    var publishedAt: String?
//    var type: String?
//}
//
//struct MaterialsAssignment: Codable {
//    var id: Int?
//    var title: String?
//    var instructions: String?
//    var duration: Int?
//    var numberOfQuestions: Int?
//    var publishedAt: String?
//    var type: String?
//}

struct MaterialsVideo: Codable {
    var id: Int?
    var title: String?
    var fileUrl: String?
    var fileName: String?
    var contentType: String?
    var type: String?
    var publishedAt: String?
}

struct MaterialsDocument: Codable {
    var id: Int?
    var title: String?
    var link: String?
    var fileUrl: String?
    var fileName: String?
    var contentType: String?
    var type: String?
    var publishedAt: String?
}
