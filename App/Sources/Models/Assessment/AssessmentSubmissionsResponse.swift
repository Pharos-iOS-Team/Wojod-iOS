// Copyright © 2020 Pharos Solutions. All rights reserved.

import Foundation

struct AssessmentSubmissionsResponse: Decodable {
    var submittedCount: Int?
    var notSubmittedCount: Int?
    var students: [AssessmentSubmittedStudents]?
}

struct AssessmentSubmittedStudents: Decodable {
    var mark: Double?
    var status: String?
    var studentName: String?
    var studentInitials: String?
    var studentId: Int?
    var submissionDate: String?
}
