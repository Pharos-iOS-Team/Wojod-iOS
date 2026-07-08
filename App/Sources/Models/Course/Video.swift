// Copyright © 2026 Pharos Solutions. All rights reserved.

import Foundation

struct Video: Codable {
    var id: Int
    var title: String?
    var fileUrl: String?
    var fileName: String?
    var contentType: String?
    var type: String?
    var publishedAt: Date?
    var vdocipherId: String?
    var duration: Int?
    var link: String?
    var viewsRemaining: Int?
    var daysRemaining: Int? 
    var lockMessage: String?
    var locked: Bool
    var bunnyLibraryId: String?
    var bunnyApiKey: String?
    var bunnyGuid: String?

    var isBunnyVideo: Bool { return bunnyGuid?.isValid ?? false }
}
