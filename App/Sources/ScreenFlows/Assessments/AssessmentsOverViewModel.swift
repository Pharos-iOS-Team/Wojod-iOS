// Copyright © 2020 Pharos Solutions GmbH. All rights reserved.

// swiftlint:disable all

import Foundation

class AssessmentsOverViewModel {
    private let decoder = JSONDecoder()

    func loadAssessments(
        studentId: Int?,
        subjectId: Int?,
        module: AssessmentsOverViewViewModel.Module,
        completionHandler: @escaping (AssessmentsResponse?, Error?) -> Void
    ) {
        let requestModel = GetAssessmentsRequestModel(studentId: studentId, subjectId: subjectId)
        ApiProvider.shared.request(.assessments(.getAssessments(requestModel: requestModel, module: module.rawValue)), decodeTo: AssessmentsResponse.self) { result in
            switch result {
            case let .success(response):
                completionHandler(response, nil)
            case let .failure(error):
                completionHandler(nil, error)
            }
        }
    }

    func assessmentResults(
        assessmentID: Int,
        studentId: Int? = nil,
        module: String,
        completionHandler: @escaping (AssessmentDetails?, Error?) -> Void
    ) {
        ApiProvider.shared.request(.assessments(.assessmentResults(assessmentID: assessmentID, requestModel: .init(studentId: studentId), module: module)), decodeTo: AssessmentDetails.self) { result in
            switch result {
            case let .success(details):
                details.questions?.forEach { $0.assessmentID = details.id }
                completionHandler(details, nil)
            case let .failure(error):
                completionHandler(nil, error)
            }
        }
    }

    private func getAssessments(
        fromResponse response: AssessmentsResponse,
        subjectId: Int?,
        module: AssessmentsOverViewViewModel.Module,
        allSubjectAssessments: [String: [Assessment]]
    ) -> [String: [Assessment]] {
        var returnedAssessments = allSubjectAssessments
        let subjects = response.subjects
        let allAssessments = getAllAssessments(response: response, module: module)
        if let subjectName = subjects?.first(where: { $0.id == subjectId })?.name,
            let subjectAssessments = allAssessments?[subjectName] {
            returnedAssessments[subjectName] = subjectAssessments.values.reduce([], { $0 + $1 })
        } else if let firstSubjectName = allAssessments?.keys.first {
            let firstSubjectAssessments = allAssessments?.values.first
            returnedAssessments[firstSubjectName] = firstSubjectAssessments?.values.reduce([], { $0 + $1 })
        }
        return returnedAssessments
    }

    private func getAllAssessments(response: AssessmentsResponse, module: AssessmentsOverViewViewModel.Module) -> [String: [String: [Assessment]]]? {
        switch module {
        case .all:
            return response.assignmentsQuizzes
        case .quizzes:
            return response.quizzes
        case .assignments:
            return response.assignments
        }
    }
}
