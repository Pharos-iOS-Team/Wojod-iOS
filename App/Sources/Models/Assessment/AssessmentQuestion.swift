// Copyright © 2021 Pharos Solutions. All rights reserved.

// swiftlint:disable all

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
    let questionAttachment: String?
    var choices: [AssessmentChoice]?
    var answerManagedObject: AssessmentAnswer?
    var isAnswered = false
    var isSingleChoice: Bool?
    var assessmentID: Int?
    var questioAnswerState: String?
    var answerState: AnswerState = .notReviewed
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
    var selectedChoices: [Int32] = [] {
        didSet {
            answerManagedObject?.setValue(selectedChoices, forKey: "choices")
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
        case 3..<11:
            return "\(formatedPoints) \(L10n.Quizzes.points)"
        default:
            return isArabic ? "\(formatedPoints) \(L10n.Quizzes.point)" : "\(formatedPoints) \(L10n.Quizzes.points)"
        }
    }

    enum QuestionType: String {
        case none = ""
        case mcq
        case trueOrFalse = "true_false"
        case freeText = "free_text"
    }

    enum AnswerState: String {
        case correct
        case incorrect
        case notReviewed = "not_reviewed"
        case needsImprovement = "needs_improvement"
    }

    private enum CodingKeys: String, CodingKey {
        case id, title, choices, comment, note, mark, position, difficulty
        case modelAnswer
        case studentMark
        case fileName
        case questionType
        case questionAttachment = "attachment"
        case attachmentType
        case submittedFileName
        case submittedAttachment
        case submittedAttachmentType
        case submittedFreeTextAnswer
        case maximumAllowedChoices
        case selectedChoices = "submittedChoices"
        case questioAnswerState = "answerState"
        case submissionId
        case isSingleChoice
        case correctionImages
    }

    // swiftlint:disable function_body_length
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        // Print all available keys in the JSON
        let allKeys = values.allKeys.map { String(describing: $0) }
        
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        submissionId = try values.decodeIfPresent(Int.self, forKey: .submissionId)
        title = try values.decodeIfPresent(String.self, forKey: .title)
        comment = try values.decodeIfPresent(String.self, forKey: .comment)
        note = try values.decodeIfPresent(String.self, forKey: .note)
        modelAnswer = try values.decodeIfPresent(String.self, forKey: .modelAnswer)
        
        // Try to decode questionType with explicit error handling
        do {
            questionType = try values.decodeIfPresent(String.self, forKey: .questionType)
        } catch {
            questionType = nil
        }
        
        mark = try values.decodeIfPresent(Double.self, forKey: .mark)
        studentMark = try values.decodeIfPresent(Double.self, forKey: .studentMark)
        position = try values.decodeIfPresent(Int.self, forKey: .position)
        difficulty = try values.decodeIfPresent(String.self, forKey: .difficulty)
        fileName = try values.decodeIfPresent(String.self, forKey: .fileName)
        questionAttachment = try values.decodeIfPresent(String.self, forKey: .questionAttachment)
        attachmentType = try values.decodeIfPresent(String.self, forKey: .attachmentType)
        submittedFileName = try values.decodeIfPresent(String.self, forKey: .submittedFileName)
        submittedAttachment = try values.decodeIfPresent(String.self, forKey: .submittedAttachment)
        submittedAttachmentType = try values.decodeIfPresent(String.self, forKey: .submittedAttachmentType)
        maximumAllowedChoices = try values.decodeIfPresent(Int.self, forKey: .maximumAllowedChoices)
        submittedFreeTextAnswer = try values.decodeIfPresent(String.self, forKey: .submittedFreeTextAnswer)
        
        // Try to decode choices with explicit error handling
        do {
            choices = try values.decodeIfPresent([AssessmentChoice].self, forKey: .choices)
        } catch {
            choices = nil
        }
        
        selectedChoices = try values.decodeIfPresent([Int32].self, forKey: .selectedChoices) ?? []
        questioAnswerState = try values.decodeIfPresent(String.self, forKey: .questioAnswerState)
        configureAnswerStatus(state: questioAnswerState)
        isAnswered = isQuestionAnswered()
        isSingleChoice = try values.decodeIfPresent(Bool.self, forKey: .isSingleChoice)
        correctionImages = try values.decodeIfPresent([CorrectionImage].self, forKey: .correctionImages)
    }

    private func configureAnswerStatus(state: String?) {
        guard let answerState = state else { return }
        self.answerState = AnswerState(rawValue: answerState) ?? .notReviewed
    }

    private func isQuestionAnswered() -> Bool {
        switch type {
        case .mcq, .trueOrFalse:
            return !selectedChoices.isEmpty ? true : false
        case .freeText where submittedFreeTextAnswer?.isValid == true:
            return true
        case .freeText where submittedAttachment?.isValid == true:
            return true
        default:
            return false
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
        if let index = selectedChoices.firstIndex(where: { $0 == id }) {
            selectedChoices.remove(at: index)
        } else {
            selectedChoices.append(id)
        }
    }

    func getSubmittedAnswerParameters(ignoreAttachment: Bool) -> [String: Any]? {
        guard let deviceToken = UIDevice.current.identifierForVendor?.uuidString else { return nil }
        var parameters = [String: Any]()
        parameters["device_token"] = deviceToken
        parameters["question_id"] = id
        parameters["choices_ids"] = selectedChoices
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

struct CorrectionImage: Codable {
    let fileUrl: String?
    let filename: String?
    let contentType: String?

    private enum CodingKeys: String, CodingKey {
        case fileUrl = "file_url"
        case filename
        case contentType = "content_type"
    }
}
