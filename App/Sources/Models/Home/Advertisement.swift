// Copyright © 2026 Pharos Solutions. All rights reserved.

import Foundation

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
