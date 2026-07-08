// Copyright © 2020 Pharos Solutions. All rights reserved.

import Foundation

struct AssessmentSubmissionsResponse: Decodable {
    var submittedCount: Int?
    var notSubmittedCount: Int?
    var students: [AssessmentSubmittedStudents]?
}
