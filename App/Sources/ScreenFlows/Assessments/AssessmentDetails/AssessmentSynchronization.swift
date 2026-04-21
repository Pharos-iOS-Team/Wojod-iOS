// Copyright © 2020 Pharos Solutions GmbH. All rights reserved.

import UIKit
import CoreData

// swiftlint:disable all

class AssessmentSynchronization {
    private let model = AssessmentDetailsModel()
    private var managedObjects = [NSManagedObject]()
    private var totalAnswersCount = 0
    var synchronizationCompletionHandler: (() -> Void)?

    func startSynchronizationForQuiz(id: Int) {
        AssessmentAnswer().fetchAll { [weak self] managedObjects in
            guard let self = self else { return }
            let quizManagedObject = self.currentQuizManagedObjects(quizID: id, allAnswers: managedObjects)
            self.managedObjects = quizManagedObject
            self.totalAnswersCount = quizManagedObject.count
            guard self.totalAnswersCount > 0 else {
                self.synchronizationCompletionHandler?()
                return
            }
            self.sendRequest(with: quizManagedObject[self.totalAnswersCount - 1])
        }
    }

    func startSynchronization() {
        fetchAnswers()
    }

    private func currentQuizManagedObjects(quizID: Int, allAnswers: [NSManagedObject]) -> [NSManagedObject] {
        var filteredManagedObjects = [NSManagedObject]()
        for item in allAnswers {
            guard
                let answer = item as? AssessmentAnswer,
                let assessmentID = answer.value(forKey: "assessmentId") as? Int
            else { return [] }
            if assessmentID == quizID {
                filteredManagedObjects.append(item)
            }
        }
        return filteredManagedObjects
    }

    private func getContext() -> NSManagedObjectContext? {
        return LocalSettingsConfiguratorAppDelegate.shared.persistentContainer.viewContext
    }

    private func fetchAnswers() {
        AssessmentAnswer().fetchAll { [weak self] managedObjects in
            guard let self = self else { return }
            self.managedObjects = managedObjects
            self.totalAnswersCount = managedObjects.count
            guard self.totalAnswersCount > 0 else {
                self.synchronizationCompletionHandler?()
                return
            }
            self.sendRequest(with: managedObjects[self.totalAnswersCount - 1])
        }
    }

    private func sendAnswerRequest(
        _ assessmentID: Int,
        _ questionID: Int,
        _ selectedChoices: [Int],
        _ freeTextAnswer: String?,
        ignoreAttachment: Bool,
        module: String
    ) {
        submitAnswerWithoutAttachment(
            assessmentID: assessmentID,
            questionID: questionID,
            selectedChoices: selectedChoices,
            freeTextAnswer: freeTextAnswer,
            ignoreAttachment: ignoreAttachment,
            module: module
        ) { error in
            self.moveToNextAnswer(shouldRemoveCurrentRequest: (error == nil))
        }
    }

    private func sendRequest(with managedObject: NSManagedObject?) {
        guard
            let answer = managedObject as? AssessmentAnswer,
            let assessmentID = answer.value(forKey: "assessmentId") as? Int,
            let questionID = answer.value(forKey: "questionId") as? Int,
            let module = answer.value(forKey: "module") as? String
        else {
            moveToNextAnswer(shouldRemoveCurrentRequest: true)
            return
        }

        if let submittedAttachment = answer.value(forKey: "attachmentURL") as? String,
            let attachmentURL = URL(string: submittedAttachment) {
            let freeTextAnswer = answer.value(forKey: "freeText") as? String
            sendUploadRequest(questionID, assessmentID, attachmentURL, freeTextAnswer, answer: answer, module: module)
        } else {
            let selectedChoices = answer.value(forKey: "choices") as? [Int] ?? []
            let freeTextAnswer = answer.value(forKey: "freeText") as? String
            sendAnswerRequest(assessmentID, questionID, selectedChoices, freeTextAnswer, ignoreAttachment: false, module: module)
        }
    }

    private func sendUploadRequest(_ questionID: Int, _ assessmentID: Int, _ attachmentURL: URL, _ freeTextAnswer: String?, answer: AssessmentAnswer?, module: String) {
        let parameters = getFreeTextParameters(questionID, freeTextAnswer, ignoreAttachment: false, ignoreFreeTextAnswer: false)
        uploadAttachement(
            assessmentID: assessmentID,
            questionID: questionID,
            fileURL: attachmentURL,
            fileName: attachmentURL.lastPathComponent,
            mimeType: attachmentURL.mimeType,
            parameters: parameters,
            module: module
        ) { error in
            self.moveToNextAnswer(shouldRemoveCurrentRequest: (error == nil))
        }
    }

    private func submitAnswerWithoutAttachment(
        assessmentID: Int?,
        questionID: Int?,
        selectedChoices: [Int],
        freeTextAnswer: String?,
        ignoreAttachment: Bool,
        module: String,
        completion: @escaping (Error?) -> Void
    ) {
        guard let assessmentID = assessmentID else { return }
        let parameters = getSubmittedAnswerParameters(questionID: questionID, selectedChoices: selectedChoices, submittedFreeTextAnswer: freeTextAnswer, ignoreAttachment: ignoreAttachment)
        model.submitAnswer(assessmentID: assessmentID, parameters: parameters, module: module) { error in
            completion(error)
        }
    }

    private func uploadAttachement(
        assessmentID: Int,
        questionID: Int?,
        fileURL: URL,
        fileName: String,
        mimeType: String,
        parameters: [String: Any],
        module: String,
        completion: @escaping (Error?) -> Void
    ) {
        model.uploadDocumentAnswer(
            assessmentID: assessmentID,
            questionID: questionID,
            fileURL: fileURL,
            fileName: fileName,
            mimeType: mimeType,
            parameters: parameters,
            module: module,
            progressCompletion: { progress in print(progress) }
        ) { _, error in
            completion(error)
        }
    }

    private func moveToNextAnswer(shouldRemoveCurrentRequest: Bool) {
        guard let answer = managedObjects[totalAnswersCount - 1] as? AssessmentAnswer else { return }
        do {
            if shouldRemoveCurrentRequest {
                answer.delete()
                try getContext()?.save()
                managedObjects.remove(at: totalAnswersCount - 1)
                totalAnswersCount -= 1
            }
            if totalAnswersCount > 0 {
                sendRequest(with: managedObjects[self.totalAnswersCount - 1])
            } else {
                synchronizationCompletionHandler?()
            }
        } catch {
            print(error)
        }
    }

    private func getSubmittedAnswerParameters(questionID: Int?, selectedChoices: [Int], submittedFreeTextAnswer: String?, ignoreAttachment: Bool) -> [String: Any] {
        guard let deviceToken = UIDevice.current.identifierForVendor?.uuidString else { return [:] }
        var parameters = [String: Any]()
        parameters["device_token"] = deviceToken
        parameters["question_id"] = questionID
        parameters["choices_ids"] = selectedChoices
        parameters["free_text_answer"] = submittedFreeTextAnswer
        parameters["ignore_attachment"] = String(ignoreAttachment)
        return parameters
    }

    private func getFreeTextParameters(
        _ questionID: Int,
        _ freeTextAnswer: String?,
        ignoreAttachment: Bool,
        ignoreFreeTextAnswer: Bool
    ) -> [String: Any] {
        guard let deviceToken = UIDevice.current.identifierForVendor?.uuidString else { return [:] }
        return [
            "device_token": deviceToken,
            "question_id": questionID,
            "free_text_answer": freeTextAnswer ?? "",
            "ignore_attachment": String(ignoreAttachment),
            "ignore_free_text_answer": String(ignoreFreeTextAnswer)
        ]
    }
}
