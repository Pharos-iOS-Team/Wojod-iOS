// Copyright © 2020 Pharos Solutions GmbH. All rights reserved.

// swiftlint:disable all

import Foundation
import Alamofire
import UIKit

class AssessmentDetailsModel: ModelDecodable {
    private let decoder = JSONDecoder()
    private var uploadRequests = [Int: UploadRequest?]()

    private func addUploadRequest(questionID: Int?, request: UploadRequest?) {
        guard let questionID = questionID else { return }
        uploadRequests[questionID] = request
    }

    private func removeUploadRequest(for questionID: Int?) {
        guard let questionID = questionID,
            let index = uploadRequests.index(forKey: questionID) else { return }
        uploadRequests.remove(at: index)
    }

    func cancelUploadRequest(for questionID: Int?) {
        guard let questionID = questionID,
            let request = uploadRequests[questionID]
            else { return }
        request?.cancel()
        removeUploadRequest(for: questionID)
    }

    func startAssessment(
        assessmentID: Int,
        deviceToken: String,
        module: String,
        completionHandler: @escaping (AssessmentDetails?, Error?) -> ()
    ) {
        APIClient.shared.startAssessment(assessmentID: assessmentID, deviceToken: deviceToken, module: module) { response in
            switch response.result {
            case .success:
                if let statusCode = response.response?.statusCode {
                    switch statusCode {
                    case 200:
                        if let data = response.data {
                            do {
                                let decoded = try self.decoder.decode(AssessmentDetails.self, from: data)
                                completionHandler(decoded, nil)
                            } catch {
                                completionHandler(nil, error)
                            }
                        }
                    default:
                        completionHandler(nil, nil)
                    }
                }
            case.failure:
                if let error = response.error {
                    completionHandler(nil, error)
                }
            }
        }
    }

    func submitAnswer(
        assessmentID: Int,
        parameters: [String: Any],
        module: String,
        completionHandler: @escaping (Error?) -> ()
    ) {
        APIClient.shared.submitAssessmentAnswer(assessmentID: assessmentID, parameters: parameters, module: module) { response in
            switch response.result {
            case .success:
                guard let statusCode = response.response?.statusCode else { completionHandler(nil); return }
                switch statusCode {
                case 200:
                    completionHandler(nil)
                default:
                    completionHandler(nil)
                }
            case .failure:
                if let error = response.error {
                    completionHandler(error)
                }
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
        let parameters: [String: Any] = ["device_token": deviceToken]
        APIClient.shared.finishAssessment(assessmentID: assessmentID, parameters: parameters, module: module) { response in
            switch response.result {
            case .success:
                completionHandler(nil)
            case .failure:
                if let error = response.error {
                    completionHandler(error)
                }
            }
        }
    }

    func downloadAttachment(
        with url: URL,
        delegate: URLSessionDownloadDelegate
    ) {
        APIClient.shared.downloadAttachment(with: url, delegate: delegate)
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
        APIClient.shared.uploadDocumentAnswer(
            assessmentID: assessmentID,
            fileData: fileData,
            fileName: fileName,
            mimeType: mimeType,
            parameters: parameters,
            module: module,
            uploadRequestCompletion: { request in
                self.addUploadRequest(questionID: questionID, request: request)
            },
            progressCompletion: { progress in
                print(progress)
                progressCompletion(progress)
            }) { response in
            self.handleUploadResponse(questionID: questionID, response, completionHandler: completionHandler)
        }
    }

    private func handleUploadResponse(
        questionID: Int?,
        _ response: AFDataResponse<Any>,
        completionHandler: @escaping (AssessmentQuestion?, Error?) -> Void
    ) {
        switch response.result {
        case .success:
            self.removeUploadRequest(for: questionID)
            do {
                guard let responseData = response.data else { return }
                let decodedQuestion = try decoder.decode(AnsweredQuestion.self, from: responseData)
                completionHandler(decodedQuestion.question, nil)
            } catch {
                completionHandler(nil, error)
            }
        case .failure:
            if let error = response.error,
                response.error?.localizedDescription != "cancelled" {
                completionHandler(nil, error)
                // UploadTracker.shared.uploadError()
                // AppAnalytics.couldNotUploadAssessmentAttachment(error: error)
            }
        }
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
            // AppAnalytics.couldNotGetFileData(error: error)
            return nil
        }
    }
}
