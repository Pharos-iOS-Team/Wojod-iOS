// Copyright © 2021 Pharos Solutions. All rights reserved.

import AVKit
import UIKit
import VdoFramework

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

    func goToChat() {
        coordinator.showChat(courseID: viewModel.course?.id ?? 0, teacherID: viewModel.teacherID ?? 0, from: self)
    }

    func dismissView() {
        removeScreenshotPreventingView()
        coordinator.dismiss(from: self)
    }

    func playCourseVideo(playerController: AVPlayerViewController) {
        addChild(playerController)
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
