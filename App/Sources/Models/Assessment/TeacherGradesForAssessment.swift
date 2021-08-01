// Copyright © 2021 Pharos Solutions GmbH. All rights reserved.

import Foundation

class TeacherLocalGradesForAssessment {
    var indexPathRow: Int?
    var mark: Double?
    var teacherComment: String?
    var submissionID: Int?
    var status: AssessmentQuestion.AnswerState?
    
    init (
        indexPathRow: Int?,
        mark: Double?,
        teacherComment: String?,
        submissionID: Int?,
        status: AssessmentQuestion.AnswerState?
    ) {
        self.indexPathRow = indexPathRow
        self.mark = mark
        self.teacherComment = teacherComment
        self.submissionID = submissionID
        self.status = status
    }
}

struct TeacherSubmitGradeRequestModel: Codable {
    var grades: [GradeRequestModel]
}

struct GradeRequestModel: Codable {
    var mark: Double
    var comment: String
    var status: String
    var submissionID: Int
}
