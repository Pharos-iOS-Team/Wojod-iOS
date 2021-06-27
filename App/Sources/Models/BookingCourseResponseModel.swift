// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

struct BookingCourseResponseModel: Codable {
    var id: Int
    var status: String?
    var receiptNumber: String?
    var studentName: String?
    var teacherName: String?
    var address: String?
    var courseName: String?
}
