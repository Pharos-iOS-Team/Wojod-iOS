// Copyright © 2026 Pharos Solutions. All rights reserved.

import Foundation

struct CoursesRequestModel: Encodable {
    let type: HomeMode
    let myCourses: Bool
    let subjectID: Int?
    let page: Int
    let limit: Int = 10
    let locale: String?
}

extension CoursesRequestModel {
    /// Excludes 'type' from encoding as it's only used for internal routing
    private enum CodingKeys: CodingKey {
        case myCourses
        case subjectID
        case page
        case limit
        case locale
    }

    /// Custom encoding to convert myCourses boolean to string ("true"/"false") as required by the API.
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(myCourses.description, forKey: .myCourses)
        try container.encodeIfPresent(subjectID, forKey: .subjectID)
        try container.encode(page, forKey: .page)
        try container.encode(limit, forKey: .limit)
        try container.encodeIfPresent(locale, forKey: .locale)
    }
}
