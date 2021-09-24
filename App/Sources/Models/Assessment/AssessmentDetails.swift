// Copyright © 2020 Pharos Solutions GmbH. All rights reserved.
// swiftlint:disable all

import Foundation
import CoreData

// MARK: - AssessmentDetails
class AssessmentDetails: Codable {
    let id: Int?
    let startedAt, finishedAt: String?
    let title, instructions, availableTo: String?
    let questions: [AssessmentQuestion]?
    let mark, studentTotalMark: Double?
    let duration, remainingDuration: Int?
    let isGradeFinal: Bool?

    var localizedNumberOfQuestionsText: String? {
        guard let questionsCount = questions?.count,
            let localizedQuestionsCount = NumberFormatter.getFormattedString(fromInt: questionsCount) else { return nil }
        let isArabic = Language.currentLanguage == .arabic
        switch questionsCount {
        case 1:
            return isArabic ? L10n.Quizzes.question : "\(localizedQuestionsCount) \(L10n.Quizzes.question )"
        case 2:
            return L10n.Quizzes.twoQuestions
        case 3..<11:
            return "\(localizedQuestionsCount) \(L10n.Quizzes.threeToTenQuestions)"
        default:
            return isArabic ? "\(localizedQuestionsCount) \(L10n.Quizzes.question)" : "\(localizedQuestionsCount) \(L10n.Quizzes.questions)"
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case startedAt = "started_at"
        case finishedAt = "finished_at"
        case availableTo = "available_to"
        case studentTotalMark = "student_total_mark"
        case id, questions, mark, duration, title, instructions
        case remainingDuration = "remaining_duration"
        case isGradeFinal = "grade_final"
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        duration = try values.decodeIfPresent(Int.self, forKey: .duration)
        remainingDuration = try values.decodeIfPresent(Int.self, forKey: .remainingDuration)
        startedAt = try values.decodeIfPresent(String.self, forKey: .startedAt)
        finishedAt = try values.decodeIfPresent(String.self, forKey: .finishedAt)
        title = try values.decodeIfPresent(String.self, forKey: .title)
        instructions = try values.decodeIfPresent(String.self, forKey: .instructions)
        availableTo = try values.decodeIfPresent(String.self, forKey: .availableTo)
        questions = try values.decodeIfPresent([AssessmentQuestion].self, forKey: .questions)
        mark = try values.decodeIfPresent(Double.self, forKey: .mark)
        studentTotalMark =  try values.decodeIfPresent(Double.self, forKey: .studentTotalMark)
        isGradeFinal = try values.decodeIfPresent(Bool.self, forKey: .isGradeFinal)
        questions?.forEach { $0.assessmentID = id }
    }

    private func setDefaultValues(module: String) {
        guard let assessmentID = id else { return }
        questions?.forEach { question in
            AssessmentAnswer(context: LocalSettingsConfiguratorAppDelegate.shared.persistentContainer.viewContext).fetchExistingAnswer(assessmentID: assessmentID, studentID: User.shared.id, questionID: id, module: module) { answer in
                guard answer != nil else { return }
                question.selectedChoices = answer?.value(forKey: "choices") as? [Int32] ?? []
                question.submittedAttachment = answer?.value(forKey: "attachmentURL") as? String
                question.submittedFreeTextAnswer = answer?.value(forKey: "freeText") as? String
            }
        }
    }
}

// MARK: - AnsweredQuestion
struct AnsweredQuestion: Codable {
    let question: AssessmentQuestion?
}
