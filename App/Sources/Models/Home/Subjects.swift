// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

struct Subjects: Codable {
    var subjects: [Subject]?
}

struct Subject: Codable {
    var id: Int?
    var name: String?
}
