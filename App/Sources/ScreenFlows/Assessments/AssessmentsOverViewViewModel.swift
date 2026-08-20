// Copyright © 2020 Pharos Solutions GmbH. All rights reserved.

// swiftlint:disable all

import Foundation
import UIKit

enum QuizGradeStatus: String {
    case graded = "Graded"
    case notGraded = "Not graded yet"
}

struct AssessmentModel {
    var title: String?
    var date: String?
    var status: String?
    var duration: String?
    var type: AssessmentStatus
    var teacher: String?
    var started: Bool
    var studentMark: String?
    var quizMark: String?
    var quizGradeStatus: QuizGradeStatus
}

class AssessmentsOverViewViewModel {
    // MARK: - enums

    enum Module: String, CaseIterable, Choice, Encodable {
        case all
        case quizzes
        case assignments
        
        var choiceTitle: String {
            switch self {
            case .all:
                return L10n.Shared.Titles.all
            case .quizzes:
                return L10n.Quizzes.title
            case .assignments:
                return L10n.Assignment.title
            }
        }
        
        var choiceSubtitle: String {
            return ""
        }
        
        var index: Int? {
            return nil
        }
        
        var subject: Subject? {
            return nil
        }
    }
    
    // MARK: - Public properties

    let model = AssessmentsOverViewModel()
    let skeletonNumberOfItemsInSection = 5
    var assessments = [Assessment]()
    var lastUserSelectedSubjectIndex: IndexPath?
    var currentModule: Module = .all
    var showQuizAlert: ((String) -> Void)?
    var shouldShowSubjects: Bool {
        return true
    }

    // MARK: - Closures

    var startAssessmentHandler: ((_ assessmentID: Int?, _ assessmentDetails: AssessmentDetails?, _ type: AssessmentType) -> Void)?
    var assessmentResultsHandler: ((_ assessmentID: Int?, _ assessmentDetails: AssessmentDetails?, _ type: AssessmentType) -> Void)?
    var showError: ((_ title: String, _ message: String) -> Void)?
    var reloadForSelectedSubject: (() -> Void)?
    var updateLoadingStatus: (() -> Void)?
    var reloadSubjectsCollectionView: (() -> Void)?

    // MARK: - Initializers

    init(module: Module) {
        currentModule = module
    }

    // MARK: - Public functions

    func getAssessment(atIndexPath indexPath: IndexPath) -> Assessment? {
        return assessments[indexPath.row]
    }

    func startAssessment(with assessment: AssessmentDomain, completion: (() -> Void)? = nil) {
        guard let assessmentID = assessment.id,
            let deviceToken = UIDevice.current.identifierForVendor?.uuidString
            else { return }
        let module: Module = assessment.type == .quiz
            ? .quizzes
            : .assignments
        AssessmentDetailsModel().startAssessment(
            assessmentID: assessmentID,
            deviceToken: deviceToken,
            module: module.rawValue
        ) { [weak self] assessmentDetails, error in
            if error == nil {
            completion?()
                self?.startAssessmentHandler?(assessmentID, assessmentDetails, assessment.type)
            } else {
                self?.showQuizAlert?(error ?? "")
            }
        }
    }
    
    func assessmentResults(for assessment: AssessmentDomain?, completion: @escaping () -> Void) {
        guard let assessmentID = assessment?.id else { return }
        let studentId = User.shared.id
        let module: Module = assessment?.type == .quiz
            ? .quizzes
            : .assignments
        model.assessmentResults(assessmentID: assessmentID, studentId: studentId, module: module.rawValue) { [weak self] assessmentDetails, error in
            completion()
            self?.assessmentResultsHandler?(assessmentID, assessmentDetails, assessment?.type ?? .quiz)
        }
    }

    func handleAssessmentNavigation(section: Int, completion: @escaping (AssessmentStatus) -> Void) {
        if AssessmentStatus.cases(assessments: assessments).indices.contains(section) {
            let validSection = AssessmentStatus.cases(assessments: assessments)[section]
            completion(validSection)
        }
    }
}
