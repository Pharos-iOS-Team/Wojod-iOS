// Copyright © 2020 Pharos Solutions. All rights reserved.

import CoreData
import Foundation

// MARK: - AssessmentDetails
class AssessmentDetails: Decodable {
    let id: Int?
    let startedAt: String?
    let finishedAt: String?
    let title: String?
    let instructions: String?
    let availableTo: String?
    let questions: [AssessmentQuestion]?
    let mark: Double?
    let studentTotalMark: Double?
    let duration: Int?
    let remainingDuration: Int?
    let gradeFinal: Bool?

    var localizedNumberOfQuestionsText: String? {
        guard let questionsCount = questions?.count,
            let localizedQuestionsCount = NumberFormatter.getFormattedString(fromInt: questionsCount) else { return nil }
        let isArabic = Language.currentLanguage == .arabic
        switch questionsCount {
        case 1:
            return isArabic ? L10n.Quizzes.question : "\(localizedQuestionsCount) \(L10n.Quizzes.question )"
        case 2:
            return L10n.Quizzes.twoQuestions
        case 3 ..< 11:
            return "\(localizedQuestionsCount) \(L10n.Quizzes.threeToTenQuestions)"
        default:
            return isArabic ? "\(localizedQuestionsCount) \(L10n.Quizzes.question)" : "\(localizedQuestionsCount) \(L10n.Quizzes.questions)"
        }
    }
}
