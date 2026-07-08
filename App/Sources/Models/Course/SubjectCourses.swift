// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

struct SubjectCourses: Codable {
    struct Teacher: Codable {
        var id: Int?
        var name: String?
        var initials: String?
    }
    var teacher: Teacher?
    var courses: [Course]?
}
