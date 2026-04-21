// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation
import UIKit

class AssessmentQuestion: Codable {
    let id: Int?
    let title: String?
    var comment: String?
    var note: String?
    var modelAnswer: String?
    let questionType: String?
    var mark: Double?
    var studentMark: Double?
    let position: Int?
    let difficulty: String?
    let fileName: String?
    let attachmentType: String?
    let submittedFileName: String?
    let submittedAttachmentType: String?
    let maximumAllowedChoices: Int?
    let attachment: String?
    var choices: [AssessmentChoice]?

    @Ignored
    var answerManagedObject: AssessmentAnswer?

    var isAnswered: Bool {
        switch type {
        case .mcq, .trueOrFalse:
            return !(submittedChoices ?? []).isEmpty
        case .freeText where submittedFreeTextAnswer?.isValid == true:
            return true
        case .freeText where submittedAttachment?.isValid == true:
            return true
        default:
            return false
        }
    }

    var isSingleChoice: Bool?
    var assessmentID: Int?
    var answerState: String?

    var parsedAnswerState: AnswerState {
        return AnswerState(rawValue: answerState ?? "") ?? .notReviewed
    }

    var submissionId: Int?
    var correctionImages: [CorrectionImage]?
    var submittedAttachment: String? {
        didSet {
            answerManagedObject?.setValue(submittedAttachment, forKey: "attachmentURL")
            answerManagedObject?.setValue(submittedFreeTextAnswer, forKey: "freeText")
        }
    }
    var submittedFreeTextAnswer: String? {
        didSet {
            answerManagedObject?.setValue(submittedAttachment, forKey: "attachmentURL")
            answerManagedObject?.setValue(submittedFreeTextAnswer, forKey: "freeText")
        }
    }

    var submittedChoices: [Int32]? {
        didSet {
            answerManagedObject?.setValue(submittedChoices ?? [], forKey: "choices")
        }
    }

    var type: QuestionType {
        return QuestionType(rawValue: questionType ?? "") ?? .none
    }

    var isMultiSelection: Bool {
        return maximumAllowedChoices ?? 1 > 1
    }

    var localizedMarkText: String? {
        guard let mark = mark,
              let formatedPoints = NumberFormatter
            .getDecimalFormattedString(fromDouble: mark) else { return nil }
        let isArabic = Language.currentLanguage == .arabic
        switch mark {
        case 1:
            return isArabic ? L10n.Quizzes.point : "\(formatedPoints) \(L10n.Quizzes.point)"
        case 2:
            return L10n.Quizzes.twoPoints
        case 3 ..< 11:
            return "\(formatedPoints) \(L10n.Quizzes.points)"
        default:
            return isArabic ? "\(formatedPoints) \(L10n.Quizzes.point)" : "\(formatedPoints) \(L10n.Quizzes.points)"
        }
    }

    func initAnswerManagedObjectIfNeeded(module: String, completion: @escaping () -> Void) {
        guard let assessmentID = assessmentID else { return }
        if answerManagedObject != nil {
            completion()
        } else {
            AssessmentAnswer(context: LocalSettingsConfiguratorAppDelegate.shared.persistentContainer.viewContext).createIfNeeded(assessmentID: assessmentID, studentID: User.shared.id, questionID: id, module: module) { answerManagedObject in
                self.answerManagedObject = answerManagedObject
                completion()
            }
        }
    }

    func deleteAnswerManagedObject() {
        answerManagedObject?.delete()
        answerManagedObject = nil
    }

    func deleteAttachment() {
        submittedAttachment = nil
    }

    func addOrRemoveOptionWith(id: Int32) {
        var currentChoices = submittedChoices ?? []
        if let index = currentChoices.firstIndex(where: { $0 == id }) {
            currentChoices.remove(at: index)
        } else {
            currentChoices.append(id)
        }
        submittedChoices = currentChoices
    }

    func getSubmittedAnswerParameters(ignoreAttachment: Bool) -> [String: Any]? {
        guard let deviceToken = UIDevice.current.identifierForVendor?.uuidString else { return nil }
        var parameters = [String: Any]()
        parameters["device_token"] = deviceToken
        parameters["question_id"] = id
        parameters["choices_ids"] = submittedChoices ?? []
        parameters["free_text_answer"] = submittedFreeTextAnswer
        parameters["ignore_attachment"] = String(ignoreAttachment)
        return parameters
    }

    func getFreeTextParameters(
        _ questionID: Int,
        _ freeTextAnswer: String?,
        ignoreAttachment: Bool,
        ignoreFreeTextAnswer: Bool
    ) -> [String: Any]? {
        guard let deviceToken = UIDevice.current.identifierForVendor?.uuidString else { return nil }
        return [
            "device_token": deviceToken,
            "question_id": questionID,
            "free_text_answer": freeTextAnswer ?? "",
            "ignore_attachment": String(ignoreAttachment),
            "ignore_free_text_answer": String(ignoreFreeTextAnswer)
        ]
    }
}
