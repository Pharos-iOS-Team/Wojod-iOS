// Copyright © 2026 Pharos Solutions. All rights reserved.

import UIKit

struct VideoDomain {
    let id: Int
    let title: String?
    let publishedAt: Date?
    let duration: Int?
    let daysRemaining: Int?
    let link: String?
    let vdocipherId: String?
    let locked: Bool
    let lockMessage: String?
    let viewsRemaining: Int?
    let isBunnyVideo: Bool
    let bunnyGuid: String?
    let bunnyLibraryId: String?
    let bunnyApiKey: String?
}

// MARK: - MaterialItemProtocol
extension VideoDomain: MaterialItemProtocol {
    var displayTitle: String? { title }
    var displayDate: String { (publishedAt ?? Date()).formattedDateString }
    var displayIcon: UIImage {
        if (link?.isEmpty ?? true) || link.isYouTubeLink == true {
            return Images.videoExtension.image
        } else {
            return Images.link.image
        }
    }
    var displayDuration: Int? { duration }
    var displayDaysRemaining: Int? { daysRemaining }
    var payload: MaterialItemPayload { .video(self) }
}
