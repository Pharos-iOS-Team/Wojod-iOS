// Copyright © 2026 Pharos Solutions. All rights reserved.

import UIKit

struct AttachmentDomain {
    let id: Int?
    let title: String?
    let fileName: String?
    let link: String?
    let fileUrl: String?
    let publishedAt: Date?
    let mappedContentType: DocumentContentType?
}

// MARK: - MaterialItemProtocol
extension  AttachmentDomain: MaterialItemProtocol {
    var displayTitle: String? { title ?? fileName }
    var displayDate: String { (publishedAt ?? Date()).formattedDateString }
    var displayIcon: UIImage {
        if let contentType = mappedContentType {
            return contentType.icon
        } else if link.isYouTubeLink {
            return Images.videoExtension.image
        } else if link != nil {
            return Images.link.image
        } else {
            return Images.unknownExtension.image
        }
    }
    var displayDuration: Int? { nil }
    var displayDaysRemaining: Int? { nil }
    var sortDate: Date { publishedAt ?? Date() }
    var payload: MaterialItemPayload { .attachment(self) }
}
