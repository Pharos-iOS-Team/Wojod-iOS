// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

struct AssessmentsResponse: Codable {
    var quizzes: [String: [String: [Assessment]]]?
    var assignments: [String: [String: [Assessment]]]?
    var assignmentsQuizzes: [String: [String: [Assessment]]]?
    var subjects: [Subject]?
}
