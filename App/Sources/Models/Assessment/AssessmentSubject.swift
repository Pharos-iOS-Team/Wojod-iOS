// Copyright © 2020 Pharos Solutions GmbH. All rights reserved.

import Foundation
import ObjectMapper

struct AssessmentSubject: Mappable, Codable {
    private enum CodingKeys: String, CodingKey {
        case id
        case name, categories
        case unreadCount = "unread_count"
        case unreadIDs = "unread_ids"
    }

    var id: Int?
    var name: String?
    var unreadIDs: [Int]?
    var unreadCount: Int?
    var categories: [SubjectCategory]?

    init?(map: Map) {
        guard map.JSON["id"] != nil else { return nil }
    }

    mutating func mapping(map: Map) {
        id          <- map["id"]
        name        <- map["name"]
        unreadIDs   <- map["unread_ids"]
        unreadCount <- map["unread_count"]
        categories  <- map["categories"]
    }
}

struct SubjectCategory: Mappable, Codable {
    var id: String?
    var name: String?

    private enum CodingKeys: String, CodingKey {
        case id = "category_id"
        case name = "category_name"
    }

    init(id: String?, name: String?) {
        self.id = id
        self.name = name
    }

    init?(map: Map) {
    }

    mutating func mapping(map: Map) {
        id          <- map["category_id"]
        name        <- map["category_name"]
    }
}

extension SubjectCategory: Choice {
    var choiceTitle: String {
        return id == "-1" ? "files.uncategorized".localiz() : (name ?? "")
    }

    var choiceSubtitle: String {
        return ""
    }

    var index: Int? {
        guard let id = id else { return nil }
        return Int(id)
    }

    var subject: Subject? {
        return nil
    }
}
