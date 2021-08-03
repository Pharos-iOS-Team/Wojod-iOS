// Copyright © 2021 Pharos Solutions GmbH. All rights reserved.

import Foundation

enum AssessmentSubmissionStatus: String, Decodable {
    case notSubmitted = "not_submitted"
    case notReviewd = "not_reviewed"
    case reviewed
    case graded
    case notGraded = "not_graded"

    var title: String {
        switch self {
        case .notSubmitted:
            return "quizzes.notSubmitted".localiz()
        case .notReviewd:
            return "assignment.notReviewed".localiz()
        case .reviewed:
            return "quizzes.reviewed".localiz()
        case .graded:
            return "quizzes.finalized".localiz()
        case .notGraded:
            return "quizzes.nonFinialized".localiz()
        }
    }
}

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
