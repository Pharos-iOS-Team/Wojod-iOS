// Copyright © 2026 Pharos Solutions. All rights reserved.

import Foundation

struct Media: Codable, ContentTypeable {
    var fileName: String?
    var fileUrl: String?
    var thumbnailUrl: String?
    var contentType: String?
    var vdocipherId: String?
    var duration: Int?
    var link: String?
    var viewsRemaining: Int?
}
