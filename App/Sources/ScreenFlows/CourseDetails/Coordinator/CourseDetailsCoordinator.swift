// Copyright © 2026 Pharos Solutions. All rights reserved.

import Combine
import ComposableArchitecture
import SafariServices
import SwiftUI
import SwiftyUserDefaults
import UIKit

final class CourseDetailsCoordinator {
    // MARK: - Properties
    private weak var viewController: CourseDetailsViewController?
    private weak var viewModel: CourseDetailsViewModel?
    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Binding

    func bind(to viewModel: CourseDetailsViewModel, presentingFrom viewController: CourseDetailsViewController) {
        self.viewModel = viewModel
        self.viewController = viewController
        subscribeToRoutes(viewModel.state.$routeSubject)
    }

    private func subscribeToRoutes(_ publisher: Published<CourseDetailsCoordinator.Route?>.Publisher) {
        publisher
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] route in self?.handle(route) }
            .store(in: &cancellables)
    }

    // MARK: - Route Handling
    // swiftlint:disable:next cyclomatic_complexity
    private func handle(_ route: CourseDetailsCoordinator.Route) {
        switch route {
        case .logout:
            logout()
        case let .showContactUs(info):
            showContactUs(info: info)
        case .showReviewCourse:
            showReviewCourse()
        case .showQROptions:
            showQROptions()
        case .showQRCodeScanner:
            showQRCodeScanner()
        case .showQRCodeManually:
            showQRCodeManually()
        case let .showReceipt(response, price):
            showReceipt(response: response, coursePrice: price)
        case let .showYouTubePlayer(url):
            showYouTubePlayer(url: url)
        case let .showBunnyPlayer(guid, lib, key, vid):
            showBunnyPlayer(guid: guid, libraryId: lib, apiKey: key, videoId: vid)
        case let .playVdoCipherVideo(video):
            playVdoCipherVideo(video: video)
        case let .openExternalURL(url):
            openExternalURL(url: url)
        case let .confirmVideoViews(video):
            confirmVideoViews(video: video)
        case let .confirmQuiz(assessment):
            confirmQuiz(assessment: assessment)
        case let .showAssessment(status, module, id, details):
            showAssessment(status: status, module: module, assessmentID: id, details: details)
        case let .didSelectVideo(video, hideViews):
            routeVideo(video, hideViews: hideViews)
        case let .didSelectDocument(document):
            routeDocument(document)
        case let .showDocument(title, url, isPdf):
            showDocument(title: title, urlString: url, isPdf: isPdf)
        case let .showSafari(url):
            showSafari(url: url)
        case let .showChat(courseID, teacherID):
            showChat(courseID: courseID, teacherID: teacherID)
        case .dismiss:
            dismiss()
        }
    }
}

// MARK: - Route Handlers
extension CourseDetailsCoordinator {
    private func routeVideo(_ video: VideoDomain, hideViews: Bool) {
        if video.isBunnyVideo {
            guard
                let guid = video.bunnyGuid,
                let libraryIdStr = video.bunnyLibraryId,
                let libraryId = Int(libraryIdStr),
                let apiKey = video.bunnyApiKey
            else {
                viewModel?.state.error = L10n.CourseDetails.Main.videoUnavailable
                return
            }
            handle(.showBunnyPlayer(guid: guid, libraryId: libraryId, apiKey: apiKey, videoId: video.id))
            return
        }

        if let linkStr = video.link, let url = URL(string: linkStr), !linkStr.isEmpty {
            handle(video.link.isYouTubeLink ? .showYouTubePlayer(url: url) : .openExternalURL(url))
            return
        }

        if !(video.vdocipherId?.isEmpty ?? true) {
            handle(hideViews ? .playVdoCipherVideo(video) : .confirmVideoViews(video))
        }
    }

    private func routeDocument(_ document: AttachmentDomain) {
        if let linkStr = document.link, let url = URL(string: linkStr) {
            handle(.showSafari(url: url))
            return
        }

        let url = AppEnvironment.baseURL.appendingPathComponent(document.fileUrl ?? "")
        let isPdf = document.mappedContentType == .pdf && AppEnvironment.appName == .squareCenter
        handle(.showDocument(
            title: document.title ?? document.fileName ?? "",
            urlString: url.absoluteString,
            isPdf: isPdf
        ))
    }

    private func showContactUs(info: String) {
        guard let viewController else { return }
        let alert = UIAlertController(title: L10n.CourseDetails.Main.contactUs, message: info, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: L10n.CourseDetails.Receipt.done, style: .default))
        viewController.present(alert, animated: true)
    }

    private func showReviewCourse() {
        guard let viewController, let viewModel else { return }
        viewController.blurView()
        let reviewViewCtrl = ReviewCourseViewController().with {
            $0.sendReview = { [weak viewModel] review in
                await viewModel?.sendReview(courseID: viewModel?.state.course?.id ?? 0, courseReview: review) ?? false
            }
            $0.onComplete = { [weak viewController] success in if success { viewController?.dismissBlurView() } }
            $0.onSkip = { [weak viewController] in viewController?.dismissBlurView() }
            $0.modalPresentationStyle = .overFullScreen
            $0.modalTransitionStyle = .crossDissolve
        }
        viewController.present(reviewViewCtrl, animated: true)
    }

    private func showQROptions() {
        viewController?.showQRCodeActionSheet()
    }

    private func showQRCodeScanner() {
        guard let viewController, let viewModel else { return }
        let scannerViewCtrl = StoryboardScene.CourseDetails.qrCodeScannerViewController.instantiate().with {
            $0.scanningCompletionHandler = { [weak viewModel] code in viewModel?.bookCourseWithQR(code) }
        }
        viewController.present(scannerViewCtrl, animated: true)
    }

    private func showQRCodeManually() {
        guard let viewController, let viewModel else { return }
        viewController.blurView()
        let qrViewCtrl = EnterQRCodeManuallyViewController().with {
            $0.scanningCompletionHandler = { [weak viewModel, weak viewController] code in
                viewController?.dismissBlurView()
                viewModel?.bookCourseWithQR(code)
            }
            $0.scanningDismissed = { [weak viewController] in viewController?.dismissBlurView() }
            $0.modalPresentationStyle = .overFullScreen
            $0.modalTransitionStyle = .crossDissolve
        }
        viewController.present(qrViewCtrl, animated: true)
    }

    private func showReceipt(response: BookingCourseResponseModel, coursePrice: String) {
        guard let viewController else { return }
        viewController.blurView()
        let receiptViewCtrl = ReceiptViewController().with {
            $0.receiptData = response
            $0.coursePrice = coursePrice
            $0.onDone = { [weak viewController] in viewController?.dismissBlurView() }
            $0.modalPresentationStyle = .overFullScreen
            $0.modalTransitionStyle = .crossDissolve
        }
        viewController.present(receiptViewCtrl, animated: true)
    }

    private func showYouTubePlayer(url: URL) {
        guard let viewController else { return }
        var initialState = YouTubePlayer.State(videoURL: url)
        initialState.isMuted = UIScreen.main.isCaptured
        let store = StoreOf<YouTubePlayer>(initialState: initialState) { YouTubePlayer() }
        let hostingViewCtrl = UIHostingController(rootView: YouTubePlayerView(store: store))
        hostingViewCtrl.modalPresentationStyle = .fullScreen
        viewController.present(hostingViewCtrl, animated: true)
    }

    private func showBunnyPlayer(guid: String, libraryId: Int, apiKey: String, videoId: Int) {
        guard let viewController, let viewModel else { return }
        let playerView = BunnyPlayerView(
            videoId: guid,
            libraryId: libraryId,
            apiKey: apiKey
        ) { [weak viewModel] completion in
            Task { _ = await viewModel?.fetchVideoDetails(videoId: "\(videoId)"); completion() }
        }
        let hostingViewCtrl = UIHostingController(rootView: playerView)
        hostingViewCtrl.modalPresentationStyle = .fullScreen
        viewController.present(hostingViewCtrl, animated: true)
    }

    private func playVdoCipherVideo(video: VideoDomain) {
        guard let viewController, let viewModel else { return }
        viewController.videoPlaybackService.presentVdoCipherVideo(
            video,
            transitioningDelegate: viewController,
            from: viewController
        ) { [weak viewModel] completion in
            Task { completion(await viewModel?.fetchVideoDetails(videoId: "\(video.id)")) }
        }
    }

    private func openExternalURL(url: URL) {
        UIApplication.shared.open(url)
    }

    private func confirmVideoViews(video: VideoDomain) {
        guard let viewController, let viewModel else { return }
        let alert = UIAlertController(
            title: L10n.Global.Titles.warning,
            message: L10n.CourseDetails.CourseReview.playVideo(video.viewsRemaining ?? 0),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: L10n.Global.Actions.confirm, style: .default) { [weak viewModel] _ in
            viewModel?.confirmVideoViews(for: video)
        })
        alert.addAction(UIAlertAction(title: L10n.Global.Actions.cancel, style: .cancel))
        viewController.present(alert, animated: true)
    }

    private func confirmQuiz(assessment: AssessmentDomain) {
        guard let viewController, let viewModel else { return }
        let alert = UIAlertController(
            title: L10n.Quizzes.alertTitle,
            message: L10n.Quizzes.alertSubTitle,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: L10n.Quizzes.start, style: .default) { [weak viewModel] _ in
            viewModel?.startAssessmentFromAlert(with: assessment)
        })
        alert.addAction(UIAlertAction(title: L10n.Global.Actions.cancel, style: .cancel) { [weak viewModel] _ in
            viewModel?.state.assessmentLoadingIndexPath = nil
        })
        viewController.present(alert, animated: true)
    }

    private func showAssessment(status: AssessmentStatus, module: AssessmentsOverViewViewModel.Module, assessmentID: Int?, details: AssessmentDetails?) {
        guard let viewController else { return }
        viewController.navigationController?.pushViewController(
            AssessmentDetailsConfigurator.configure(
                status: status,
                module: module,
                assessmentID: assessmentID,
                assessmentDetails: details
            ) { _ in },
            animated: true
        )
    }

    private func showDocument(title: String, urlString: String, isPdf: Bool) {
        guard let viewController else { return }
        let viewerViewCtrl = DocumentViewerViewController(title: title, urlString: urlString, isPdf: isPdf)
        let navViewCtrl = UINavigationController(rootViewController: viewerViewCtrl)
        navViewCtrl.modalPresentationStyle = .overFullScreen
        viewController.present(navViewCtrl, animated: true)
    }

    private func showSafari(url: URL) {
        guard let viewController else { return }
        viewController.present(SFSafariViewController(url: url), animated: true)
    }

    private func showChat(courseID: Int, teacherID: Int) {
        guard let viewController else { return }
        let chatViewCtrl = StoryboardScene.Chat.chatContainerViewController.instantiate().with {
            $0.modalPresentationStyle = .fullScreen
            $0.chatType = .teacher(courseID: courseID, teacherID: teacherID)
        }
        viewController.present(chatViewCtrl, animated: true)
    }

    private func dismiss() {
        guard let viewController else { return }
        viewController.removeScreenshotPreventingView()
        viewController.dismiss(animated: true)
    }

    private func logout() {
        User.shared.setLoggedOut()
        Defaults[\.isGuestModeEnabled] = false
        ScreensFlowConfigurationAppDelegate.shared.navigateToMainScreen()
    }
}
