// Copyright © 2026 Pharos Solutions. All rights reserved.

import Foundation

struct Attachment: Codable, ContentTypeable {
    var id: Int?
    var title: String?
    var link: String?
    var fileName: String?
    var fileUrl: String?
    var contentType: String?
    var type: String?
    var publishedAt: Date?

    var isAudio: Bool { contentType?.contains("audio") ?? false }
}
