// Copyright © 2026 Pharos Solutions. All rights reserved.

import Foundation
import SwiftyUserDefaults

struct Course: Codable {
    let id: Int
    let batchID: Int?
    let subjectID: Int?
    let name: String?
    let batchName: String?
    let price: String?
    let media: Media?
    let video: Media?
    let summary: String?
    let rating: Double?
    let reviewsCount: Int?
    var reservationState: String?
    let receipt: Receipt?
    let lessonsUnreadCount: Int?
    let materialsUnreadCount: Int?
    let qrCodeEnabled: Bool?
    let contactUsInfo: String?

    var parsedState: CourseState {
        CourseState(rawValue: reservationState ?? "") ?? .normal
    }

    var coursePrice: String {
        guard !Defaults[\.isGuestModeEnabled] else { return "" }
        guard let price, price.isValid else { return L10n.Home.Course.returnToTeacher  }

        return "\(L10n.Home.Course.price) \(price)"
    }
}
