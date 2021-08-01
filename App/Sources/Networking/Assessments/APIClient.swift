// Copyright © 2021 Pharos Solutions. All rights reserved.

// swiftlint:disable all

import Alamofire
import Foundation
import LanguageManager_iOS
import SwiftyUserDefaults

enum RequestHeaders: String {
    case accessToken = "access-token"
    case uid
    case client
}

final class APIClient: ApiManager {
    static let shared = APIClient()
    private let assessmentsAPIClient = AssessmentsAPIClient()
    private let assessmentDetailsAPIClient = AssessmentDetailsAPIClient()

    func getHeaders() -> HTTPHeaders {
        let accessToken = KeychainHandler.shared.userToken
        if let uid = User.shared.uid, let client = User.shared.client {
            return ["access-token": accessToken ?? "", "uid": uid, "client": client]
        }
        return [:]
    }

    func getAssessments(studentId: Int?, subjectId: Int?, module: AssessmentsOverViewViewModel.Module, completionHandler: @escaping (_ response: AFDataResponse<Any>) -> Void) {
        assessmentsAPIClient.getAssessments(
            studentId: studentId,
            subjectId: subjectId,
            module: module,
            completionHandler: completionHandler
        )
    }
    
    func startAssessment(
        assessmentID: Int,
        deviceToken: String,
        module: String,
        completionHandler: @escaping (_ response: AFDataResponse<Any>) -> ()
    ) {
        assessmentDetailsAPIClient.startAssessment(assessmentID: assessmentID, deviceToken: deviceToken, module: module, completionHandler: completionHandler)
    }
    
    func submitAssessmentAnswer(
        assessmentID: Int,
        parameters: [String: Any],
        module: String,
        completionHandler: @escaping (_ response: AFDataResponse<Any>) -> ()
    ) {
        assessmentDetailsAPIClient.submitAnswer(assessmentID: assessmentID, parameters: parameters, module: module, completionHandler: completionHandler)
    }
    
    func finishAssessment(
        assessmentID: Int,
        parameters: [String: Any],
        module: String,
        completionHandler: @escaping (_ response: AFDataResponse<Any>) -> ()
    ) {
        assessmentDetailsAPIClient.finishAssessment(assessmentID: assessmentID, parameters: parameters, module: module, completionHandler: completionHandler)
    }
    
    func assessmentResults(
        assessmentID: Int,
        studentId: Int? = nil,
        module: String,
        completionHandler: @escaping (_ response: AFDataResponse<Any>) -> ()
    ) {
        assessmentDetailsAPIClient.assessmentResults(assessmentID: assessmentID, studentId: studentId, module: module, completionHandler: completionHandler)
    }
    
    func downloadAttachment(
        with url: URL,
        delegate: URLSessionDownloadDelegate
    ) {
        assessmentDetailsAPIClient.downloadAttachment(with: url, delegate: delegate)
    }
    
    // swiftlint:disable function_parameter_count
    func uploadDocumentAnswer(
        assessmentID: Int,
        fileData: Data?,
        fileName: String,
        mimeType: String,
        parameters: [String: Any],
        module: String,
        uploadRequestCompletion: @escaping (UploadRequest?) -> Void,
        progressCompletion: @escaping (Double) -> Void,
        completionHandler: @escaping (_ response: AFDataResponse<Any>) -> Void
    ) {
        return assessmentDetailsAPIClient.uploadDocumentAnswer(
            assessmentID: assessmentID,
            fileData: fileData,
            fileName: fileName,
            mimeType: mimeType,
            parameters: parameters,
            module: module,
            uploadRequestCompletion: uploadRequestCompletion,
            progressCompletion: progressCompletion,
            completionHandler: completionHandler
        )
    }

    func appendStudentIdToURLIfNeeded(url: inout String, studentId: Int?) {
        if let studentID = studentId {
            url += "?student_id=\(studentID)"
        }
    }
}
