// Copyright © 2020 Pharos Solutions GmbH. All rights reserved.

import Foundation
import Alamofire

class AssessmentsAPIClient: ApiManager {
    func getAssessmentSubmissions(
        requestData: AssessmentSubmissionRequestModel,
        completionHandler: @escaping (_ response: AFDataResponse<Any>) -> ()
    ) {
        let url = "\(hostUrl)/\(requestData.module.rawValue)/\(requestData.assessmentID)"
        let headers = APIClient.shared.getHeaders()
        let params = getParameters()
        manager.request(
            url,
            method: .get,
            parameters: params,
            encoding: URLEncoding(destination: .queryString),
            headers: headers
        )
        .responseJSON(completionHandler: completionHandler)
    }

    func getSubmissionDetails(
        requestModel: AssessmentSubmissionDetailsRequestModel,
        completionHandler: @escaping (_ response: AFDataResponse<Any>) -> ()
    ) {
        let url = "\(hostUrl)/\(requestModel.module.rawValue)/\(requestModel.assessmentID)/student_submission_details"
        let headers = APIClient.shared.getHeaders()
        var params = getParameters()
        params ["student_id"] = requestModel.studentID
        manager.request(
            url,
            method: .get,
            parameters: params,
            encoding: URLEncoding(destination: .queryString),
            headers: headers
        )
        .responseJSON(completionHandler: completionHandler)
    }

    func getAssessments(
        studentId: Int?,
        subjectId: Int?,
        module: AssessmentsOverViewViewModel.Module,
        completionHandler: @escaping (_ response: AFDataResponse<Any>) -> Void
    ) {
        let assessmentsEndPoint = module == .all
            ? "assignments/assignments_quizzes"
            : module.rawValue
        let url = "\(hostUrl)/\(assessmentsEndPoint)"
        let headers = APIClient.shared.getHeaders()
        let parameters = getParameters(subjectID: subjectId)
        manager.request(
            url,
            method: .get,
            parameters: parameters,
            encoding: URLEncoding(destination: .queryString),
            headers: headers
        )
            .responseJSON(completionHandler: completionHandler)
    }
    
    private func getParameters(subjectID: Int? = nil) -> [String: Any] {
        var parameters = [String: Any]()
        parameters["student_id"] = User.shared.id
        parameters["subject_id"] = subjectID
        return parameters
    }

    private func generateDictionaryBodyOfTeacherGrades(requestBody: TeacherSubmitGradeRequestModel) -> [String: Any] {
        var arrayOfGrades: [[String: Any]] = []
        for grade in requestBody.grades {
            let gradeDictionary = [
                "id": grade.submissionID,
                "comment": grade.comment,
                "mark": grade.mark,
                "status": grade.status
            ] as [String : Any]
            arrayOfGrades.append(gradeDictionary)
        }
        return ["grades": arrayOfGrades]
    }
}
