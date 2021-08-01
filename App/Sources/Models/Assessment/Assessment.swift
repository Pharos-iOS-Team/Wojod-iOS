// Copyright © 2020 Pharos Solutions GmbH. All rights reserved.

import Foundation

struct Assessment: Codable {
    var id: Int?
    var title: String?
    var instructions: String?
    var passMark: Double?
    var studentMark: Double?
    var gradeIsFinal: Bool?
    var duration: Int?
    var started: Bool?
    var status: String?
    var type: String?
    // var assessmentType: AssessmentType = .quiz
    var publishedAt: String?
}
