// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

struct Advertisements: Codable {
    var advertisements: [Advertisement]?
}

struct Advertisement: Codable {
    var id: Int?
    var title: String?
    var webLink: String?
    var mobileLink: String?
    var description: String?
    var createdAt: String?
    var updatedAt: String?
    var media: Media?
}
