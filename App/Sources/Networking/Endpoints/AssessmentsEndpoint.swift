// Copyright © 2026 Pharos Solutions. All rights reserved.

import Foundation
import Moya

enum AssessmentsEndpoint {
    case getAssessments(requestModel: GetAssessmentsRequestModel, module: String)
    case getAssessmentSubmissions(requestModel: StudentIdRequestModel, module: String, assessmentID: Int)
    case getSubmissionDetails(AssessmentSubmissionRequestModel)
    case startAssessment(assessmentID: Int, requestModel: DeviceTokenRequestModel, module: String)
    case submitAnswer(assessmentID: Int, requestModel: SubmitAnswerRequestModel, module: String)
    case finishAssessment(assessmentID: Int, requestModel: DeviceTokenRequestModel, module: String)
    case assessmentResults(assessmentID: Int, requestModel: StudentIdRequestModel, module: String)
    case uploadDocumentAnswer(assessmentID: Int, fileData: Data?, fileName: String, mimeType: String, parameters: [String: Any], module: String)
}

extension AssessmentsEndpoint: TargetType {
    var path: String {
        switch self {
        case let .getAssessments(_, module):
            let endpoint = module == "all"
                ? "assignments/assignments_quizzes"
                : module
            return "/\(endpoint)"
        case let .getAssessmentSubmissions(_, module, assessmentID):
            return "/\(module)/\(assessmentID)"
        case let .getSubmissionDetails(requestModel):
            return "/\(requestModel.module.rawValue)/\(requestModel.assessmentID)/student_submission_details"
        case let .startAssessment(assessmentID, _, module):
            return "/\(module)/\(assessmentID)/start"
        case let .submitAnswer(assessmentID, requestModel, module):
            return "/\(module)/\(assessmentID)/submit_one_answer"
        case let .finishAssessment(assessmentID, _, module):
            return "/\(module)/\(assessmentID)/finish"
        case let .assessmentResults(assessmentID, _, module):
            return "/\(module)/\(assessmentID)/results"
        case let .uploadDocumentAnswer(assessmentID, _, _, _, _, module):
            return "/\(module)/\(assessmentID)/submit_one_answer"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getAssessments, .getAssessmentSubmissions, .getSubmissionDetails, .assessmentResults:
            return .get
        case .startAssessment, .submitAnswer, .finishAssessment, .uploadDocumentAnswer:
            return .post
        }
    }

    var task: Task {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601
        
        switch self {
        case let .getAssessments(requestModel, _):
            do {
                return .requestParameters(
                    parameters: try requestModel.toDictionary(encoder: encoder),
                    encoding: URLEncoding.queryString
                )
            } catch {
                return .requestPlain
            }

        case let .getAssessmentSubmissions(requestModel, _, _):
            do {
                return .requestParameters(
                    parameters: try requestModel.toDictionary(encoder: encoder),
                    encoding: URLEncoding.queryString
                )
            } catch {
                return .requestPlain
            }

        case let .getSubmissionDetails(requestModel):
            do {
                return .requestParameters(
                    parameters: try requestModel.toDictionary(encoder: encoder),
                    encoding: URLEncoding.queryString
                )
            } catch {
                return .requestPlain
            }

        case let .startAssessment(_, requestModel, _):
            do {
                return .requestParameters(
                    parameters: try requestModel.toDictionary(encoder: encoder),
                    encoding: URLEncoding.queryString
                )
            } catch {
                return .requestPlain
            }

        case let .submitAnswer(_, requestModel, _):
            do {
                return .requestParameters(
                    parameters: try requestModel.toDictionary(encoder: encoder),
                    encoding: JSONEncoding.default
                )
            } catch {
                return .requestPlain
            }

        case let .finishAssessment(_, requestModel, _):
            do {
                return .requestParameters(
                    parameters: try requestModel.toDictionary(encoder: encoder),
                    encoding: URLEncoding(destination: .queryString)
                )
            } catch {
                return .requestPlain
            }

        case let .assessmentResults(_, requestModel, _):
            do {
                return .requestParameters(
                    parameters: try requestModel.toDictionary(encoder: encoder),
                    encoding: URLEncoding.default
                )
            } catch {
                return .requestPlain
            }

        case let .uploadDocumentAnswer(_, fileData, fileName, mimeType, parameters, _):
            var multipartFormData: [Moya.MultipartFormData] = []
            if let data = fileData, !data.isEmpty {
                multipartFormData.append(
                    Moya.MultipartFormData(provider: .data(data), name: "attachment", fileName: fileName, mimeType: mimeType)
                )
            }
            for (key, value) in parameters {
                if let data = "\(value)".data(using: .utf8) {
                    multipartFormData.append(
                        Moya.MultipartFormData(provider: .data(data), name: key)
                    )
                }
            }
            return .uploadMultipart(multipartFormData)
        }
    }
}
