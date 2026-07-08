// Copyright © 2020 Pharos Solutions GmbH. All rights reserved.

// swiftlint:disable all

import Foundation
import Moya
import UIKit

class AssessmentDetailsModel {
    private var cancellables = [Int: Cancellable]()

    private func addCancellable(questionID: Int?, cancellable: Cancellable) {
        guard let questionID = questionID else { return }
        cancellables[questionID] = cancellable
    }

    private func removeCancellable(for questionID: Int?) {
        guard let questionID = questionID,
            let index = cancellables.index(forKey: questionID) else { return }
        cancellables.remove(at: index)
    }

    func cancelUploadRequest(for questionID: Int?) {
        guard let questionID = questionID,
            let cancellable = cancellables[questionID]
            else { return }
        cancellable.cancel()
        removeCancellable(for: questionID)
    }

    func startAssessment(
        assessmentID: Int,
        deviceToken: String,
        module: String,
        completionHandler: @escaping (AssessmentDetails?, String?) -> ()
    ) {
        ApiProvider.shared.request(.assessments(.startAssessment(assessmentID: assessmentID, requestModel: .init(deviceToken: deviceToken), module: module)), decodeTo: AssessmentDetails.self) { result in
            switch result {
            case let .success(details):
                details.questions?.forEach { $0.assessmentID = details.id }
                completionHandler(details, nil)
            case let .failure(error):
                completionHandler(nil, error.localizedDescription)
            }
        }
    }

    func submitAnswer(
        assessmentID: Int,
        parameters: [String: Any],
        module: String,
        completionHandler: @escaping (Error?) -> ()
    ) {
        let choicesIds = (parameters["choices_ids"] as? [Any])?.compactMap { Int("\($0)") }
        let nonEmptyChoicesIds = choicesIds?.isEmpty == false ? choicesIds : nil
        let requestModel = SubmitAnswerRequestModel(
            deviceToken: parameters["device_token"] as? String ?? "",
            questionId: parameters["question_id"] as? Int,
            choicesIds: nonEmptyChoicesIds,
            freeTextAnswer: parameters["free_text_answer"] as? String,
            ignoreAttachment: parameters["ignore_attachment"] as? String ?? "false"
        )
        ApiProvider.shared.request(.assessments(.submitAnswer(assessmentID: assessmentID, requestModel: requestModel, module: module))) { result in
            switch result {
            case .success:
                completionHandler(nil)
            case let .failure(error):
                completionHandler(error)
            }
        }
    }

    func finishAssessment(
        assessmentID: Int,
        module: String,
        completionHandler: @escaping (Error?) -> ()
    ) {
        guard let deviceToken = UIDevice.current.identifierForVendor?.uuidString
            else { return }
        ApiProvider.shared.request(.assessments(.finishAssessment(assessmentID: assessmentID, requestModel: .init(deviceToken: deviceToken), module: module))) { result in
            switch result {
            case .success:
                completionHandler(nil)
            case let .failure(error):
                completionHandler(error)
            }
        }
    }

    func downloadAttachment(
        with url: URL,
        delegate: URLSessionDownloadDelegate
    ) {
        let configuration = URLSessionConfiguration.default
        let operationQueue = OperationQueue()
        let session = URLSession(configuration: configuration, delegate: delegate, delegateQueue: operationQueue)
        let downloadTask = session.downloadTask(with: url)
        downloadTask.resume()
    }

    // swiftlint:disable function_parameter_count
    func uploadDocumentAnswer(
        assessmentID: Int,
        questionID: Int?,
        fileURL: URL?,
        fileName: String,
        mimeType: String,
        parameters: [String: Any],
        module: String,
        progressCompletion: @escaping (Double) -> Void,
        completionHandler: @escaping (AssessmentQuestion?, Error?) -> Void
    ) {
        let fileData = getFileData(from: fileURL)
        let endpoint = Endpoint.assessments(.uploadDocumentAnswer(
            assessmentID: assessmentID,
            fileData: fileData,
            fileName: fileName,
            mimeType: mimeType,
            parameters: parameters,
            module: module
        ))
        let cancellable = ApiProvider.shared.upload(endpoint, decodeTo: ApiResponse<AssessmentQuestion>.self,
            progress: { progress in
                progressCompletion(progress)
            },
            completion: { [weak self] result in
                switch result {
                case let .success(decodedQuestion):
                    self?.removeCancellable(for: questionID)
                    completionHandler(decodedQuestion.data, nil)
                case let .failure(error):
                    if error.localizedDescription != "cancelled" {
                        completionHandler(nil, error)
                    }
                }
            }
        )
        addCancellable(questionID: questionID, cancellable: cancellable)
    }

    private func getFileData(from url: URL?) -> Data? {
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
            guard let fileUrl = matchedFileURL else { return nil }
            let data = try Data(contentsOf: fileUrl)
            return data
        } catch {
            return nil
        }
    }
}
