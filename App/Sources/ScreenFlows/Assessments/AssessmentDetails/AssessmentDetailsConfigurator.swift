// Copyright © 2020 Pharos Solutions GmbH. All rights reserved.

// swiftlint:disable all

import Foundation

class AssessmentDetailsConfigurator {
    class func configure(status: AssessmentStatus, module: AssessmentsOverViewViewModel.Module, assessmentID: Int?, assessmentDetails: AssessmentDetails?, delegate: AssessmentDetailsDelegate?) -> AssessmentDetailsViewController {
        let viewModel = AssessmentDetailsViewModel(
            status: status,
            module: module,
            assessmentID: assessmentID,
            assessmentDetails: assessmentDetails
        )
        let assessmentDetailsViewController = StoryboardScene.AssessmentDetails.assessmentDetailsViewController.instantiate()
        assessmentDetailsViewController.setViewModel(viewModel)
        assessmentDetailsViewController.hidesBottomBarWhenPushed = true
        return assessmentDetailsViewController
    }

    class func configure(
        status: AssessmentStatus,
        module: AssessmentsOverViewViewModel.Module,
        assessmentID: Int?,
        assessmentDetails: AssessmentDetails?,
        submittedStudentData: AssessmentSubmittedStudents? = nil
    ) -> AssessmentDetailsViewController {
        let viewModel = AssessmentDetailsViewModel(
            status: status,
            module: module,
            assessmentID: assessmentID,
            assessmentDetails: assessmentDetails,
            submittedStudentData: submittedStudentData
        )
        let assessmentDetailsViewController = StoryboardScene.AssessmentDetails.assessmentDetailsViewController.instantiate()
        assessmentDetailsViewController.setViewModel(viewModel)
        assessmentDetailsViewController.hidesBottomBarWhenPushed = true
        return assessmentDetailsViewController
    }
}
