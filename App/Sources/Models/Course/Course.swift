// Copyright © 2026 Pharos Solutions. All rights reserved.

import Foundation

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
    let reservationState: String?
    let receipt: Receipt?
    let lessonsUnreadCount: Int?
    let materialsUnreadCount: Int?
    let qrCodeEnabled: Bool?
    let contactUsInfo: String?

    var parsedReservationState: CourseState {
        CourseState(rawValue: reservationState ?? "") ?? .normal
    }
}
