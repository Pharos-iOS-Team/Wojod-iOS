// Copyright © 2026 Pharos Solutions. All rights reserved.

import Foundation

struct Receipt: Codable {
    var id: Int?
    var receiptNumber: String?
    var studentName: String?
    var teacherName: String?
    var courseName: String?
    var address: String?
    var reservationState: String?
    var price: String?
}
