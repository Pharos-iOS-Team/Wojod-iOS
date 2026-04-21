// Copyright © 2026 Pharos Solutions. All rights reserved.

import Foundation

struct Review: Codable {
    struct Reviewer: Codable {
        var id: Int
        var name: String?
        var initials: String?
        var avatar: Avatar?
    }

    var id: Int
    var title: String?
    var comment: String?
    var rating: Double?
    var createdAt: String?
    var reviewer: Reviewer?
}
