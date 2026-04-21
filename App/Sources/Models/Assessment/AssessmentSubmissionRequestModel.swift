// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

struct AssessmentSubmissionRequestModel: Encodable {
    var studentID: Int?
    var assessmentID: Int
    var module: AssessmentsOverViewViewModel.Module
}
