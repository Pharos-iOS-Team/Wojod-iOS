// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

class TeacherLocalGradesForAssessment {
    var indexPathRow: Int?
    var mark: Double?
    var teacherComment: String?
    var submissionID: Int?
    var status: AnswerState?

    init (
        indexPathRow: Int?,
        mark: Double?,
        teacherComment: String?,
        submissionID: Int?,
        status: AnswerState?
    ) {
        self.indexPathRow = indexPathRow
        self.mark = mark
        self.teacherComment = teacherComment
        self.submissionID = submissionID
        self.status = status
    }
}
