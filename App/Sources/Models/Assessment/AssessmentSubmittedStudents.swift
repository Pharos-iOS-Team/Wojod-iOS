// Copyright © 2026 Pharos Solutions. All rights reserved.

import Foundation

struct AssessmentSubmittedStudents: Decodable {
    var mark: Double?
    var status: String?
    var studentName: String?
    var studentInitials: String?
    var studentId: Int?
    var submissionDate: String?
}
