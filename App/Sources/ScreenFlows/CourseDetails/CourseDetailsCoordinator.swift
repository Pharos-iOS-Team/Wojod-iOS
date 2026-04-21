// Copyright © 2026 Pharos Solutions. All rights reserved.

import ComposableArchitecture
import SafariServices
import SwiftUI
import SwiftyUserDefaults
import UIKit

protocol CourseDetailsNavigationCoordinating: AnyObject {
    func showReceipt(_ receiptData: BookingCourseResponseModel, coursePrice: String, from viewController: UIViewController)
    func showContactUs(info: String, from viewController: UIViewController)
    func showReviewCourse(delegate: ReviewCourseViewDelegate, from viewController: UIViewController)
    func showQRCodeScanner(completion: @escaping (String) -> Void, from viewController: UIViewController)
    func showQRCodeManually(from viewController: UIViewController, completion: @escaping (String?) -> Void, onDismiss: @escaping () -> Void)
    func showYouTubePlayer(url: URL, from viewController: UIViewController)
    func showBunnyPlayer(guid: String, libraryId: Int, apiKey: String, from viewController: UIViewController)
    func showAssessmentDetails(status: AssessmentStatus, module: AssessmentsOverViewViewModel.Module, assessmentID: Int?, assessmentDetails: AssessmentDetails?, delegate: AssessmentDetailsDelegate?, from viewController: UIViewController)
    func showPDF(url: URL, from viewController: UIViewController)
    func showSafari(url: URL, from viewController: UIViewController)
    func showChat(courseID: Int, teacherID: Int, from viewController: UIViewController)
    func dismiss(from viewController: UIViewController)
    func logout()
}

final class CourseDetailsCoordinator: CourseDetailsNavigationCoordinating {
    func showReceipt(_ receiptData: BookingCourseResponseModel, coursePrice: String, from viewController: UIViewController) {
        let receiptViewCtrl = ReceiptViewController().with {
            $0.receiptData = receiptData
            $0.coursePrice = coursePrice
            $0.delegate = viewController as? ReceiptDoneButtonDelegate
            $0.modalPresentationStyle = .overFullScreen
            $0.modalTransitionStyle = .crossDissolve
        }
        viewController.present(receiptViewCtrl, animated: true)
    }

    func showContactUs(info: String, from viewController: UIViewController) {
        let alert = UIAlertController(
            title: L10n.CourseDetails.Main.contactUs,
            message: info,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: L10n.CourseDetails.Receipt.done, style: .default))
        viewController.present(alert, animated: true)
    }

    func showReviewCourse(delegate: ReviewCourseViewDelegate, from viewController: UIViewController) {
        let reviewViewCtrl = ReviewCourseViewController().with {
            $0.delegate = delegate
            $0.modalPresentationStyle = .overFullScreen
            $0.modalTransitionStyle = .crossDissolve
        }
        viewController.present(reviewViewCtrl, animated: true)
    }

    func showQRCodeScanner(completion: @escaping (String) -> Void, from viewController: UIViewController) {
        let viewCtrl = StoryboardScene.CourseDetails.qrCodeScannerViewController.instantiate().with {
            $0.scanningCompletionHandler = completion
        }
        viewController.present(viewCtrl, animated: true)
    }

    func showQRCodeManually(from viewController: UIViewController, completion: @escaping (String?) -> Void, onDismiss: @escaping () -> Void) {
        let qrViewCtrl = EnterQRCodeManuallyViewController().with {
            $0.scanningCompletionHandler = completion
            $0.scanningDismissed = onDismiss
            $0.modalPresentationStyle = .overFullScreen
            $0.modalTransitionStyle = .crossDissolve
        }
        viewController.present(qrViewCtrl, animated: true)
    }

    func showYouTubePlayer(url: URL, from viewController: UIViewController) {
        var initialState = YouTubePlayer.State(videoURL: url)
        initialState.isMuted = UIScreen.main.isCaptured
        let store = StoreOf<YouTubePlayer>(initialState: initialState) { YouTubePlayer() }
        let hostingController = UIHostingController(rootView: YouTubePlayerView(store: store))
        hostingController.modalPresentationStyle = .fullScreen
        viewController.present(hostingController, animated: true)
    }

    func showBunnyPlayer(guid: String, libraryId: Int, apiKey: String, from viewController: UIViewController) {
        let playerView = BunnyPlayerView(videoId: guid, libraryId: libraryId, apiKey: apiKey)
        let hostingController = UIHostingController(rootView: playerView)
        hostingController.modalPresentationStyle = .fullScreen
        viewController.present(hostingController, animated: true)
    }

    func showAssessmentDetails(
        status: AssessmentStatus,
        module: AssessmentsOverViewViewModel.Module,
        assessmentID: Int?,
        assessmentDetails: AssessmentDetails?,
        delegate: AssessmentDetailsDelegate?,
        from viewController: UIViewController
    ) {
        viewController.navigationController?.navigationBar.isHidden = false
        viewController.navigationController?.pushViewController(
            AssessmentDetailsConfigurator.configure(
                status: status,
                module: module,
                assessmentID: assessmentID,
                assessmentDetails: assessmentDetails,
                delegate: delegate
            ),
            animated: true
        )
    }

    func showPDF(url: URL, from viewController: UIViewController) {
        let pdfViewCtrl = PDFViewController(itemUrl: url) { [weak viewController] in
            viewController?.dismiss(animated: true)
        }
        let navController = UINavigationController(rootViewController: pdfViewCtrl)
        navController.modalPresentationStyle = .fullScreen
        viewController.present(navController, animated: true)
    }

    func showSafari(url: URL, from viewController: UIViewController) {
        let safariViewCtrl = SFSafariViewController(url: url)
        viewController.present(safariViewCtrl, animated: true)
    }

    func showChat(courseID: Int, teacherID: Int, from viewController: UIViewController) {
        let viewCtrl = StoryboardScene.Chat.chatContainerViewController.instantiate().with {
            $0.modalPresentationStyle = .fullScreen
            $0.chatType = .teacher(courseID: courseID, teacherID: teacherID)
        }
        viewController.present(viewCtrl, animated: true)
    }

    func dismiss(from viewController: UIViewController) {
        viewController.dismiss(animated: true)
    }

    func logout() {
        User.shared.setLoggedOut()
        Defaults[\.isGuestModeEnabled] = false
        ScreensFlowConfigurationAppDelegate.shared.navigateToMainScreen()
    }
}
