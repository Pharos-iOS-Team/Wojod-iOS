// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

struct ReviewsModel: Codable {
    var reviews: [Review]?
}

struct Review: Codable {
    var id: Int
    var title: String?
    var comment: String?
    var rating: Int?
    var createdAt: String?
    var reviewer: Reviewer?
}

struct Reviewer: Codable {
    var id: Int
    var name: String?
    var initials: String?
    var avatar: Avatar?
}
