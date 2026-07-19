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
}

// MARK: - DomainModel

extension Video {
    var domainModel: VideoDomain {
        VideoDomain(
            id: id,
            title: title,
            publishedAt: publishedAt,
            duration: duration,
            daysRemaining: daysRemaining,
            link: link,
            vdocipherId: vdocipherId,
            locked: locked,
            lockMessage: lockMessage,
            viewsRemaining: viewsRemaining,
            isBunnyVideo: bunnyGuid?.isValid ?? false,
            bunnyGuid: bunnyGuid,
            bunnyLibraryId: bunnyLibraryId,
            bunnyApiKey: bunnyApiKey
        )
    }
}
