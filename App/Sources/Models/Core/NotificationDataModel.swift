// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

struct NotificationDataModel: Codable {
    var id: Int?
    var link: String?
    var topic: String?
    var message: String?
    var creator: String?
    var createdAt: String?
    var attachments: [Attachment]?
}
