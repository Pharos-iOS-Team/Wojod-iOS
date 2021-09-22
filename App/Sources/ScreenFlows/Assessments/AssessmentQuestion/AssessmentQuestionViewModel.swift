// Copyright © 2020 Pharos Solutions GmbH. All rights reserved.
// swiftlint:disable all

import Foundation
import Alamofire
import UIKit

class AssessmentQuestionViewModel {
    // MARK: - Private properties

    private let model = AssessmentDetailsModel()
    private var assessmentQuestion: AssessmentQuestion?
    private var assessmentStatus: AssessmentStatus?
    private var questionImages = [Int: UIImage]()

    // MARK: - Public properties

    var module: AssessmentsOverViewViewModel.Module = .quizzes
    var dataSource = [QuestionSection]()
    var isMultiSelection: Bool? {
        return assessmentQuestion?.isMultiSelection
    }

    var getAssessmentStatus: AssessmentStatus? {
        return assessmentStatus
    }

    var textAlignment: NSTextAlignment {
        guard let title = assessmentQuestion?.title else { return .left }
        if NSLinguisticTagger.dominantLanguage(for: title) == "ar" {
            return .right
        } else {
            return Language.textAlignment
        }
    }

    var questionID: Int? {
        return assessmentQuestion?.id
    }

    var questionMarkText: String? {
        guard assessmentStatus == .open else { return nil }
        return assessmentQuestion?.localizedMarkText
    }
    
    var questionHeaderText: String? {
        switch assessmentQuestion?.type {
        case .trueOrFalse:
            return "quizzes.chooseOneAnswer".localiz()
        case .mcq:
            return "quizzes.chooseOneOrMoreAnswers".localiz()
        case .freeText:
            return "quizzes.writeAnswer".localiz()
        default:
            return nil
        }
    }

    var attachmentsProgressStatus = [Int: Double]()
    var isDownloadingAttachments = [Int: Bool]()

    var currentProgress: Double {
        guard let questionID = questionID else { return 0.0 }
        return attachmentsProgressStatus[questionID] ?? 0.0
    }

    enum QuestionSection {
        case header(_ title: String, _ image: UIImage?, _ hasImage: Bool)
        case body(_ items: [QuestionSectionItem])
        case note(_ note: String?)
    }
    
    enum QuestionSectionItem {
        case selectableOption(
            _ title: String,
            _ imageURL: String?,
            _ isSelected: Bool,
            _ isCorrectAnswer: Bool?,
            _ isOpenAssessment: Bool
        )
        case textView(
            _ answer: String?,
            _ alignment: NSTextAlignment,
            _ attachmentURLString: String?,
            _ isAnswered: Bool,
            _ isCorrectAnswer: Bool?,
            _ answerState: AssessmentQuestion.AnswerState,
            _ question: AssessmentQuestion?,
            _ isComment: Bool?
        )
        case teacherCommentHeader(comment: String?)
        case teacherComment(comment: String?)
    }

    // MARK: - Closures

    var reloadData: (() -> Void)?

    // MARK: - Private functions

    private func resetDataSource() {
        dataSource.removeAll()
    }

    private func reloadDataSource() {
        prepareDataSource()
        reloadData?()
    }

    private func isCorrectFreeTextAnswer(for question: AssessmentQuestion) -> Bool? {
        let mark = question.studentMark
        return mark == nil ? nil : (mark ?? 0.0 > 0.0)
    }

    private func appendFreeTextSection(for question: AssessmentQuestion, answer: String?, isCorrectAnswer: Bool?, isComment: Bool? = false) {
        let freeTextQuestionItem: QuestionSectionItem = .textView(
            answer,
            textAlignment,
            question.submittedAttachment,
            assessmentStatus == .closed,
            isCorrectAnswer,
            question.answerState,
            question,
            isComment
        )
        let questionSection: QuestionSection = .body([freeTextQuestionItem])
        dataSource.append(questionSection)
    }

    private func appendMCQSection(question: AssessmentQuestion) {
        var questionSection = [QuestionSectionItem]()
        question.choices?.forEach { choice in
            let matchedChoice = question.choices?.first { $0.id == choice.id }
            let isChoiceSelected = question.selectedChoices.contains(choice.id ?? -1)
            questionSection.append(
                .selectableOption(
                    choice.title ?? "",
                    choice.attachment,
                    isChoiceSelected,
                    assessmentStatus == .open
                        ? nil
                        : isCorrectMCQAnswer(question: question, choice: matchedChoice),
                    assessmentStatus == .open
                )
            )
        }
        dataSource.append(.body(questionSection))
    }

    private func isCorrectMCQAnswer(question: AssessmentQuestion, choice: AssessmentChoice?) -> Bool? {
        guard let choiceID = choice?.id else { return nil }
        if question.selectedChoices.contains(choiceID),
            choice?.modelAnswer == true {
            return true
        } else if question.selectedChoices.contains(choiceID),
            choice?.modelAnswer == false {
            return false
        } else if !question.selectedChoices.contains(choiceID),
            choice?.modelAnswer == true {
            return true
        } else {
            return nil
        }
    }

    private func downloadImage(with urlString: String?) {
        guard let urlString = urlString,
            let imageURL = URL(string: "\(Environment.baseURL)\(urlString)"),
            let questionID = questionID
            else { return }
        AF.request(imageURL).responseImage { response in
            if case .success(let image) = response.result,
                questionID == self.questionID {
                self.questionImages[questionID] = image
                self.reloadDataSource()
            }
        }
    }

    private func getActualFileURL(from url: URL?) -> URL? {
        guard let documentDirectory = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first else { return nil }
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(
                at: documentDirectory,
                includingPropertiesForKeys: nil
            )
            let matchedFileURL = fileURLs.first {
                $0.lastPathComponent == url?.lastPathComponent
            }
            return matchedFileURL
        } catch {
            return nil
        }
    }

    // MARK: - Public functions

    func updateQuestionWith(comment: String) {
        assessmentQuestion?.comment = comment
        prepareDataSource() 
    }

    func setCurrentQuestion(question: AssessmentQuestion?) {
        self.assessmentQuestion = question
        downloadImage(with: question?.questionAttachment)
    }

    func prepareDataSource() {
        guard let question = assessmentQuestion else { return }
        resetDataSource()
        dataSource.append(.header(question.title ?? "", questionImages[question.id ?? -1], question.questionAttachment?.isValid == true))
        switch question.type {
        case .mcq, .trueOrFalse:
            appendMCQSection(question: question)
        case .freeText:
            appendFreeTextSection(for: question, answer: question.submittedFreeTextAnswer, isCorrectAnswer: isCorrectFreeTextAnswer(for: question))
            if module == .quizzes,
                assessmentStatus == .closed,
                let comment = question.comment,
                comment.isValid {
                appendFreeTextSection(for: question, answer: comment, isCorrectAnswer: true, isComment: true)
            }
        default:
            return
        }
        if !(question.note?.isEmpty ?? true) {
            dataSource.append(.note(question.note))
        }
    }

    func setAssessmentStatus(_ status: AssessmentStatus?) {
        self.assessmentStatus = status
    }

    func numberOfSections() -> Int {
        return dataSource.count
    }
    
    func numberOfRows(for section: Int) -> Int {
        let questionSection = dataSource[section]
        switch questionSection {
        case .header:
            return 1
        case .body(let items):
            return items.count
        case .note(_):
            return 1
        }
    }

    func didSelectOption(at indexPath: IndexPath) {
        let section = dataSource[indexPath.section]
        switch section {
        case .body(let items):
            let item = items[indexPath.row]
            if case .selectableOption = item {
                guard let type = assessmentQuestion?.type,
                      let optionID = assessmentQuestion?.choices?[indexPath.row].id
                else { return }
                assessmentQuestion?.initAnswerManagedObjectIfNeeded(module: module.rawValue) {
                    switch type {
                    case .trueOrFalse:
                        self.assessmentQuestion?.selectedChoices = [optionID]
                    case .mcq:
                        self.assessmentQuestion?.addOrRemoveOptionWith(id: optionID)
                    default:
                        return
                    }
                    self.reloadDataSource()
                }
            }
        default:
            return
        }
    }

    func setFreeTextAnswer(_ text: String?) {
        assessmentQuestion?.initAnswerManagedObjectIfNeeded(module: module.rawValue) {
            self.assessmentQuestion?.submittedFreeTextAnswer = text ?? ""
        }
    }

    func getFreeTextAnswer() -> String? {
        return assessmentQuestion?.submittedFreeTextAnswer
    }

    func setAttachedFileLocalURL(url: URL) {
        assessmentQuestion?.initAnswerManagedObjectIfNeeded(module: module.rawValue) {
            self.assessmentQuestion?.submittedAttachment = url.absoluteString
            self.reloadDataSource()
        }
    }

    func getAttachmentURL() -> (URL?, Bool) {
        guard let submittedAttachment = assessmentQuestion?.submittedAttachment else {
            return (nil, false)
        }
        if submittedAttachment.starts(with: "file:"),
           let actualURL = getActualFileURL(from: URL(string: submittedAttachment)) {
            return (actualURL, false)
        } else {
            return (URL(string: "\(Environment.baseURL)\(submittedAttachment)"), true)
        }
    }

    func deleteQuestionAttachment() {
        assessmentQuestion?.initAnswerManagedObjectIfNeeded(module: module.rawValue) {
            let freeTextAnswer = self.assessmentQuestion?.submittedFreeTextAnswer
            self.assessmentQuestion?.deleteAttachment()
            self.assessmentQuestion?.submittedFreeTextAnswer = freeTextAnswer
        }
    }
}
