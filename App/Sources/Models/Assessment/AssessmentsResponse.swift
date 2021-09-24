// Copyright © 2021 Pharos Solutions GmbH. All rights reserved.

import Foundation

struct AssessmentsResponse: Codable {
    var quizzes: [String: [String: [Assessment]]]?
    var assignments: [String: [String: [Assessment]]]?
    var assessments: [String: [String: [Assessment]]]?
    var subjects: [Subject]?

    private enum CodingKeys: String, CodingKey {
        case quizzes, assignments, subjects
        case assessments = "assignments_quizzes"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        quizzes = try values.decodeIfPresent([String: [String: [Assessment]]].self, forKey: .quizzes)
        assignments = try values.decodeIfPresent([String: [String: [Assessment]]].self, forKey: .assignments)
        assessments = try values.decodeIfPresent([String: [String: [Assessment]]].self, forKey: .assessments)
        subjects = try values.decodeIfPresent([Subject].self, forKey: .subjects)
        // setAssessmentsStatus(quizzes)
        // setAssessmentsStatus(assignments)
        // setAssessmentsStatus(assessments)
    }

//    private func setAssessmentsStatus(_ list: [String: [String: [Assessment]]]?) {
//        guard let list = list else { return }
//        list.values.forEach { subjectAssessments in
//            for (key, value) in subjectAssessments {
//                value.forEach { $0.status = AssessmentStatus(rawValue: key) }
//            }
//        }
//    }
}
