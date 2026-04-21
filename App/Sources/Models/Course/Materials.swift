// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

struct Materials: Codable {
    var quizzes: [Assessment]?
    var assignments: [Assessment]?
    var videos: [Video]?
    var documents: [MaterialsDocument]?

    mutating func sort() {
        quizzes?.sort { $0.publishedAt > $1.publishedAt }
        assignments?.sort { $0.publishedAt > $1.publishedAt }
        videos?.sort { $0.publishedAt ?? Date() > $1.publishedAt ?? Date() }
        documents?.sort {
            if let date1 = $0.publishedAt, let date2 = $1.publishedAt {
                return date1 > date2
            }
            return false
        }
    }
}

struct MaterialsDocument: Codable {
    var id: Int?
    var title: String?
    var link: String?
    var fileUrl: String?
    var fileName: String?
    var contentType: String?
    var type: String?
    var publishedAt: Date?
}
