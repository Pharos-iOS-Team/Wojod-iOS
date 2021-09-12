// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

struct Notifications: Codable {
    var notifications: [NotificationDataModel]?
}

struct NotificationDataModel: Codable {
    var id: Int?
    var link: String?
    var topic: String?
    var message: String?
    var creator: String?
    var createdAt: String?
    var attachments: [Attachment]?
}

struct Attachment: Codable {
    var id: Int?
    var filename: String?
    var fileUrl: String?
    var contentType: String?
}
