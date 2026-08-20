// Copyright © 2026 Pharos Solutions. All rights reserved.

import Foundation

extension CourseDetailsCoordinator {
    enum Route {
        // MARK: - Auth
        case logout

        // MARK: - Course Actions
        case showContactUs(info: String)
        case showReviewCourse
        case showQROptions
        case showQRCodeScanner
        case showQRCodeManually
        case showReceipt(BookingCourseResponseModel, coursePrice: String)

        // MARK: - Video
        case showYouTubePlayer(url: URL)
        case showBunnyPlayer(guid: String, libraryId: Int, apiKey: String, videoId: Int)
        case playVdoCipherVideo(VideoDomain)
        case openExternalURL(URL)
        case confirmVideoViews(VideoDomain)

        // MARK: - Assessment
        case showAssessment(
            status: AssessmentStatus,
            module: AssessmentsOverViewViewModel.Module,
            assessmentID: Int?,
            details: AssessmentDetails?
        )
        case confirmQuiz(AssessmentDomain)

        // MARK: - Item Selection Intents
        case didSelectVideo(VideoDomain, hideViews: Bool)
        case didSelectDocument(AttachmentDomain)

        // MARK: - Documents & Safari
        case showDocument(title: String, urlString: String, isPdf: Bool)
        case showSafari(url: URL)

        // MARK: - Navigation
        case showChat(courseID: Int, teacherID: Int)
        case dismiss
    }
}
