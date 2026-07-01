// Copyright © 2021 Pharos Solutions. All rights reserved.

import AVKit
import UIKit
import VdoFramework

// MARK: - CollapseExpandDelegate

extension CourseDetailsViewController: CollapseExpandDelegate {
    func didTapOnCollapseExpand(in section: Int) {
        viewModel.toggleSectionExpansion(section) { [weak self] in
            self?.tableView.reloadData()
        }
    }
}

// MARK: - CourseDetailsInfoHeaderDelegate

extension CourseDetailsViewController: CourseDetailsInfoHeaderDelegate {
    func showDetails() {
        viewModel.activeScreen = .details
        tableView.reloadData()
    }

    func showMaterials() {
        viewModel.activeScreen = .materials
        loadActiveTab()
    }

    func showReviews() {
        viewModel.activeScreen = .reviews
        loadActiveTab()
    }

    private func loadActiveTab() {
        let isFirstLoad = !loadedTabs.contains(viewModel.activeScreen)
        if isFirstLoad {
            viewModel.clearTabData()
            viewModel.isLoadingTab = true
            tableView.reloadData()
            showContentSpinner()
        } else {
            tableView.reloadData()
        }
        viewModel.handleRefreshingAccordingToOpenedTab { [weak self] in
            guard let self else { return }
            self.loadedTabs.insert(self.viewModel.activeScreen)
            if isFirstLoad {
                self.viewModel.isLoadingTab = false
                self.hideContentSpinner()
            }
            self.tableView.reloadData()
        }
    }

    func goToChat() {
        coordinator.showChat(courseID: viewModel.course.id, teacherID: teacherID ?? 0, from: self)
    }

    func dismissView() {
        removeScreenshotPreventingView()
        coordinator.dismiss(from: self)
    }

    func playCourseVideo(playerController: AVPlayerViewController) {
        addChild(playerController)
    }
}

// MARK: - ReceiptDoneButtonDelegate

extension CourseDetailsViewController: ReceiptDoneButtonDelegate {
    func didTapDone() {
        dismissBlurView()
    }
}

// MARK: - ReviewCourseViewDelegate

extension CourseDetailsViewController: ReviewCourseViewDelegate {
    func didTapSendButton(courseReview: CourseReview) {
        viewModel.sendReview(courseID: viewModel.course?.id ?? 0, courseReview: courseReview) { [weak self] isSentSuccessfully in
            if isSentSuccessfully { self?.dismissBlurView() }
        }
    }

    func didTapSkipButton() {
        dismissBlurView()
    }
}

// MARK: - AssessmentDetailsDelegate

extension CourseDetailsViewController: AssessmentDetailsDelegate {
    func didFinishAssessment(with id: Int?) {
        tableView.reloadData()
    }
}

// MARK: - AssetPlaybackDelegate + UIViewControllerTransitioningDelegate

extension CourseDetailsViewController: AssetPlaybackDelegate, UIViewControllerTransitioningDelegate {
    func streamPlaybackManager(playerReadyToPlay player: AVPlayer) {
        videoPlaybackService.streamPlaybackManager(playerReadyToPlay: player)
    }

    func streamPlaybackManager(playerCurrentItemDidChange player: AVPlayer) {
        videoPlaybackService.streamPlaybackManager(playerCurrentItemDidChange: player)
    }

    func streamLoadError(error: VdoFramework.VdoError) {
        hideLoadingIndicator()
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        videoPlaybackService.invalidateTimer()
        return nil
    }
}
