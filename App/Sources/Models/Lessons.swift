// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

struct LessonsModel: Codable {
    var lessons: [Lesson]
}

struct Lesson: Codable {
    var id: Int
    var name: String
    var locked: Bool
    var lockMessage: String
}
