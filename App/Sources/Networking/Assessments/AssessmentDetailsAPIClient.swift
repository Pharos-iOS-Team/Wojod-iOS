// Copyright © 2020 Pharos Solutions GmbH. All rights reserved.

import Foundation
import Alamofire

class AssessmentDetailsAPIClient: ApiManager {
    func startAssessment(
        assessmentID: Int,
        deviceToken: String,
        module: String,
        completionHandler: @escaping (_ response: AFDataResponse<Any>) -> ()
    ) {
        var url = "\(hostUrl)/\(module)/\(assessmentID)/start"
        url = appendStudentIDIfNeeded(url: &url)
        let headers = APIClient.shared.getHeaders()
        let parameters: [String: Any] = ["device_token": deviceToken]
        manager.request(
            url,
            method: .post,
            parameters: parameters,
            encoding: URLEncoding(destination: .queryString),
            headers: headers
        )
        .responseJSON(completionHandler: completionHandler)
    }
    
    func submitAnswer(
        assessmentID: Int,
        parameters: [String: Any],
        module: String,
        completionHandler: @escaping (_ response: AFDataResponse<Any>) -> ()
    ) {
        var url = "\(hostUrl)/\(module)/\(assessmentID)/submit_one_answer"
        url = appendStudentIDIfNeeded(url: &url)
        let headers = APIClient.shared.getHeaders()
        let request = manager.request(
            url,
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default,
            headers: headers
        )
        request.responseJSON(completionHandler: completionHandler)
    }
    
    func finishAssessment(
        assessmentID: Int,
        parameters: [String: Any],
        module: String,
        completionHandler: @escaping (_ response: AFDataResponse<Any>) -> ()
    ) {
        var url = "\(hostUrl)/\(module)/\(assessmentID)/finish"
        url = appendStudentIDIfNeeded(url: &url)
        let headers = APIClient.shared.getHeaders()
        let request = manager.request(
            url,
            method: .post,
            parameters: parameters,
            encoding: URLEncoding.default,
            headers: headers
        )
        request.responseJSON(completionHandler: completionHandler)
    }
    
    func assessmentResults(
        assessmentID: Int,
        studentId: Int? = nil,
        module: String,
        completionHandler: @escaping (_ response: AFDataResponse<Any>) -> ()
    ) {
        var url = "\(hostUrl)/\(module)/\(assessmentID)/results"
        APIClient.shared.appendStudentIdToURLIfNeeded(url: &url, studentId: studentId)
        let headers = APIClient.shared.getHeaders()
        let request = manager.request(
            url,
            method: .get,
            encoding: URLEncoding.default,
            headers: headers
        )
        request.responseJSON(completionHandler: completionHandler)
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
        fileData: Data?,
        fileName: String,
        mimeType: String,
        parameters: [String: Any],
        module: String,
        uploadRequestCompletion: @escaping (UploadRequest?) -> Void,
        progressCompletion: @escaping (Double) -> Void,
        completionHandler: @escaping (_ response: AFDataResponse<Any>) -> Void
    ) {
        var url = "\(hostUrl)/\(module)/\(assessmentID)/submit_one_answer"
        url = appendStudentIDIfNeeded(url: &url)
        let headers = APIClient.shared.getHeaders()
        let request = manager.upload(
            multipartFormData: { (multipartFormData) in
                if let data = fileData, !data.isEmpty {
                    multipartFormData.append(data, withName: "attachment", fileName: fileName, mimeType: mimeType)
                }
                for (key, value) in parameters {
                    if let data = "\(value)".data(using: String.Encoding.utf8) {
                        multipartFormData.append(data, withName: key as String)
                    }
                }
            },
            to: url,
            method: .post,
            headers: headers
        )
        request.responseJSON(completionHandler: completionHandler)
        request.uploadProgress { progress in
            progressCompletion(progress.fractionCompleted)
        }
    }

    private func appendStudentIDIfNeeded(url: inout String) -> String {
        return url
    }
}
