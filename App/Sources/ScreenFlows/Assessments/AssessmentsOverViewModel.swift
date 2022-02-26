// Copyright © 2020 Pharos Solutions GmbH. All rights reserved.

// swiftlint:disable all

import Foundation
import Alamofire

class AssessmentsOverViewModel {
    private let decoder = JSONDecoder()

    func assessmentResults(
        assessmentID: Int,
        studentId: Int? = nil,
        module: String,
        completionHandler: @escaping (AssessmentDetails?, Error?) -> Void
    ) {
        APIClient.shared.assessmentResults(assessmentID: assessmentID, studentId: studentId, module: module) { response in
            switch response.result {
            case .success:
                if let statusCode = response.response?.statusCode {
                    switch statusCode {
                    case 200..<300:
                        do {
                            guard let data = response.data else { return }
                            let assessmentDetails = try self.decoder.decode(AssessmentDetails.self, from: data)
                            completionHandler(assessmentDetails, nil)
                        } catch {
                            completionHandler(nil, error)
                        }
                    default:
                        completionHandler(nil, nil)
                    }
                }
            case .failure:
                if let error = response.error {
                    completionHandler(nil, error)
                }
            }
        }
    }

    private func getAssessmentForUserRole(
        fromResponse response: AFDataResponse<Any>,
        subjectId: Int?,
        module: AssessmentsOverViewViewModel.Module,
        allSubjectAssessments: [String: [Assessment]]
    ) -> [String: [Assessment]]? {
        return getAssessments(fromResponse: response, subjectId: subjectId, module: module, allSubjectAssessments: allSubjectAssessments)
    }

    private func getAssessments(
        fromResponse response: AFDataResponse<Any>,
        subjectId: Int?,
        module: AssessmentsOverViewViewModel.Module,
        allSubjectAssessments: [String: [Assessment]]
    ) -> [String: [Assessment]] {
        var returnedAssessments = allSubjectAssessments
        if let data = response.data {
            do {
                let assessments = try decoder.decode(AssessmentsResponse.self, from: data)
                let subjects = assessments.subjects
                let allAssessments = getAllAssessments(response: assessments, module: module)
                if let subjectName = subjects?.first(where: { $0.id == subjectId })?.name,
                    let subjectAssessments = allAssessments?[subjectName] {
                    returnedAssessments[subjectName] = subjectAssessments.values.reduce([], { $0 + $1 })
                } else if let firstSubjectName = allAssessments?.keys.first {
                    let firstSubjectAssessments = allAssessments?.values.first
                    returnedAssessments[firstSubjectName] = firstSubjectAssessments?.values.reduce([], { $0 + $1 })
                }
            } catch {
                // AppAnalytics.couldNotGetAssessments(error: error)
            }
        }
        return returnedAssessments
    }

    private func getAllAssessments(response: AssessmentsResponse, module: AssessmentsOverViewViewModel.Module) -> [String: [String: [Assessment]]]? {
        switch module {
        case .all:
            return response.assessments
        case .quizzes:
            return response.quizzes
        case .assignments:
            return response.assignments
        }
    }
}
