// Copyright © 2026 Pharos Solutions. All rights reserved.

import Combine
import Foundation
import SwiftyUserDefaults

final class CourseDetailsViewModel: NSObject {
    // MARK: - Subtypes

    final class State: ObservableObject {
        @Published var error: String?
        @Published var isLoading: Bool = false
        @Published var isContentLoading: Bool = false
        @Published var isLoadingTab: Bool = false

        // Models
        @Published var course: Course?
        @Published var materialsDomain: MaterialDomain?
        @Published var lessonsList: [Lesson] = []
        @Published var reviewsList: [Review] = []
        @Published var attachmentsOfLessons: [Int: MaterialDomain] = [:]

        // Metadata & Selections
        @Published var teacherName: String?
        @Published var teacherID: Int?
        @Published var lessonNumbersList: [Int]?
        @Published var selectedAssessmentSection: Int?
        @Published var assessmentLoadingIndexPath: IndexPath?

        // UI State
        @Published var hideViews: Bool = false
        @Published var activeScreen: ActiveScreen = .details
        @Published var activeSubscreen: CourseDetailsActiveSubScreen = .details
        @Published var loadedTabs: Set<ActiveScreen> = []
        @Published var expandedSections: [Int] = []
        @Published var doesLessonContainAttachments: [Int: Bool] = [:]
        @Published var didSetInitialContentOffset: Bool = false

        @Published var routeSubject: CourseDetailsCoordinator.Route?
    }

    // MARK: - Instance Properties

    private let repository: CourseDetailsRepositoryProtocol
    let assessmentsViewModel: AssessmentsOverViewViewModel
    var state: State = .init()
    var cancellables: Set<AnyCancellable> = []

    var isContactInfoAvailable: Bool {
        state.course?.contactUsInfo?.isValid ?? false
    }

    var shouldShowQRButton: Bool {
        (state.course?.qrCodeEnabled ?? false) && state.course?.parsedState == .normal
    }

    // MARK: - Initializer

    init(service: CourseDetailsRepositoryProtocol = CourseDetailsRepository()) {
        self.repository = service
        self.assessmentsViewModel = AssessmentsOverViewViewModel(module: .all)
        super.init()
        bindAssessmentHandlers()
    }

    func viewWillAppear() {
        guard state.course != nil else { return }
        switch state.activeScreen {
        case .materials:
            let isFirstLoad = !state.loadedTabs.contains(.materials)
            if isFirstLoad { state.isContentLoading = true }
            Task { @MainActor [weak self] in
                guard let self else { return }
                await handleRefreshingAccordingToOpenedTab()
                state.loadedTabs.insert(.materials)
                if isFirstLoad { state.isContentLoading = false }
            }
        case .details:
            state.isContentLoading = true
            Task { @MainActor [weak self] in
                guard let self else { return }
                await loadCourseLessonsWithDetails()
                state.isContentLoading = false
            }
        case .reviews:
            break
        }
    }

    func didSelectItem(at indexPath: IndexPath) {
        switch state.activeScreen {
        case .details:
            handleDetailsSelection(at: indexPath)
        case .materials:
            handleMaterialsSelection(at: indexPath)
        case .reviews:
            return
        }
    }

    func handleActionButtonTapped() {
        if isGuestModeEnabled() {
            state.routeSubject = .logout
        } else {
            switch state.course?.parsedState ?? .normal {
            case .normal:
                guard isContactInfoAvailable, let info = state.course?.contactUsInfo else { return }
                state.routeSubject = .showContactUs(info: info)
            case .booked:
                state.routeSubject = .showReviewCourse
            default:
                return
            }
        }
    }

    func handleQRBookingTapped() {
        if isGuestModeEnabled() {
            state.routeSubject = .logout
        } else {
            state.routeSubject = .showQROptions
        }
    }

    func handleTabSelected(_ screen: ActiveScreen) {
        guard state.activeScreen != screen else { return }
        state.activeScreen = screen
        loadActiveTab()
    }

    func chatTapped() {
        guard let courseID = state.course?.id, let teacherID = state.teacherID else { return }
        state.routeSubject = .showChat(courseID: courseID, teacherID: teacherID)
    }

    func dismissTapped() {
        state.routeSubject = .dismiss
    }

    func confirmVideoViews(for video: VideoDomain) {
        state.routeSubject = .playVdoCipherVideo(video)
    }

    func bookCourseWithQR(_ qrCode: String?) {
        Task { @MainActor [weak self] in
            guard let self, let courseID = state.course?.id else { return }
            do {
                let response = try await repository.bookCourse(courseID: courseID, qrCode: qrCode)
                let shouldShowReceipt = handleBookingSuccess(bookingResponse: response, isQR: qrCode != nil)
                await loadCourseDetails()
                if shouldShowReceipt {
                    state.routeSubject = .showReceipt(response, coursePrice: state.course?.price ?? "")
                }
            } catch let error as WJError {
                state.error = error.message
            } catch {
                state.error = error.localizedDescription
            }
        }
    }

    func startAssessmentFromAlert(with assessment: AssessmentDomain) {
        state.isLoading = true
        assessmentsViewModel.startAssessment(with: assessment)
    }

    func loadActiveTab() {
        let isFirstLoad = !state.loadedTabs.contains(state.activeScreen)
        if isFirstLoad {
            clearTabData()
            state.isLoadingTab = true
            state.isContentLoading = true
        }
        Task { @MainActor [weak self] in
            guard let self else { return }
            await handleRefreshingAccordingToOpenedTab()
            state.loadedTabs.insert(state.activeScreen)
            if isFirstLoad {
                state.isLoadingTab = false
                state.isContentLoading = false
            }
        }
    }

    func clearTabData() {
        switch state.activeScreen {
        case .details:
            state.lessonsList = []
            state.lessonNumbersList = nil
            state.attachmentsOfLessons = [:]
            state.doesLessonContainAttachments = [:]
            state.expandedSections = []
        case .materials:
            state.materialsDomain = nil
        case .reviews:
            state.reviewsList = []
        }
    }

    func loadCourseDetails() async {
        guard let courseID = state.course?.id else { return }
        await MainActor.run { state.isLoading = true }
        defer { Task { @MainActor in state.isLoading = false } }
        do {
            let response = try await repository.loadCourse(courseID: "\(courseID)")
            state.course = response.course
            state.hideViews = response.hideViews ?? false
        } catch {
            state.error = error.localizedDescription
        }
    }

    func loadCourseLessons() async {
        guard let courseID = state.course?.id else { return }
        do {
            let lessons = try await repository.loadLessons(courseID: courseID)
            state.lessonsList = lessons
            generateLessonsNumbersList()
        } catch {
            state.error = error.localizedDescription
        }
    }

    func handleRefreshingAccordingToOpenedTab() async {
        guard let courseID = state.course?.id else { return }
        do {
            switch state.activeScreen {
            case .details:
                await loadCourseLessonsWithDetails()
            case .materials:
                state.materialsDomain = try await repository.loadMaterials(courseID: courseID)
            case .reviews:
                state.reviewsList = try await repository.loadReviews(courseID: courseID)
            }
        } catch {
            state.error = error.localizedDescription
        }
    }

    func generateLessonsNumbersList() {
        guard state.lessonsList.count >= 1 else { return }
        state.lessonNumbersList = Array(1 ... state.lessonsList.count)
    }

    func numberOfRowsForLesson(section: Int) -> Int {
        guard state.expandedSections.contains(section) else { return 0 }
        return state.attachmentsOfLessons[section]?.allMaterials.count ?? 0
    }

    func attachmentsOfLessons(for section: Int) -> [MaterialItemProtocol] {
        state.attachmentsOfLessons[section]?.allMaterials ?? []
    }

    func courseHeaderModel() -> CourseHeaderModel {
        CourseHeaderModel.make(
            course: state.course,
            teacherName: state.teacherName,
            activeScreen: state.activeScreen,
        )
    }

    func lessonHeaderModel(for section: Int) -> LessonHeaderModel {
        LessonHeaderModel.make(
            section: section,
            lesson: state.lessonsList[section],
            lessonNumber: state.lessonNumbersList?[section] ?? 0,
            isExpanded: state.expandedSections.contains(section),
            reservationState: state.course?.parsedState,
            doesContainAttachments: state.doesLessonContainAttachments[section] ?? false
        )
    }

    func toggleSectionExpansion(_ section: Int, completion: @escaping () -> Void) {
        guard !state.lessonsList[section].locked else {
            state.error = state.lessonsList[section].lockMessage
            return
        }
        guard state.course?.parsedState == .booked else { return }
        if state.expandedSections.contains(section) {
            state.expandedSections.removeAll { $0 == section }
        } else {
            state.expandedSections.append(section)
        }
        completion()
    }

    func prefetchAllLessonDetails() async {
        guard state.course?.parsedState == .booked else { return }
        let result = await repository.fetchAllAttachments(for: state.lessonsList)
        state.attachmentsOfLessons = result.attachments
        state.doesLessonContainAttachments = result.contains
    }

    func loadCourseLessonsWithDetails() async {
        await loadCourseLessons()
        await prefetchAllLessonDetails()
    }

    func handleBookingSuccess(bookingResponse: BookingCourseResponseModel?, isQR: Bool) -> Bool {
        if !isQR { state.course?.reservationState = CourseState.pending.rawValue }
        return !isTestingAccount()
    }

    func cancelBookingCourse(courseID: Int) async -> Bool {
        (try? await repository.cancelBookingCourse(courseID: courseID)) != nil
    }

    func sendReview(courseID: Int, courseReview: CourseReview) async -> Bool {
        (try? await repository.sendReview(courseID: courseID, courseReview: courseReview)) ?? false
    }

    func fetchVideoDetails(videoId: String) async -> EncryptedVideoResponse? {
        try? await repository.fetchVideoDetails(videoId: videoId)
    }

    func updateVideo(videoId: String, updateObject: UpdateObject) async {
        do {
            try await repository.updateVideo(videoId: videoId, updateObject: updateObject)
        } catch {
            state.error = error.localizedDescription
        }
    }

    func isGuestModeEnabled() -> Bool {
        Defaults[\.isGuestModeEnabled]
    }
}

// MARK: - Private Helpers
extension CourseDetailsViewModel {
    private func bindAssessmentHandlers() {
        assessmentsViewModel.startAssessmentHandler = { [weak self] assessmentID, assessmentDetails, type in
            guard let self else { return }
            let module: AssessmentsOverViewViewModel.Module = type == .quiz ? .quizzes : .assignments
            state.isLoading = false
            state.assessmentLoadingIndexPath = nil
            state.routeSubject = .showAssessment(status: .open, module: module, assessmentID: assessmentID, details: assessmentDetails)
        }
        assessmentsViewModel.assessmentResultsHandler = { [weak self] assessmentID, assessmentDetails, type in
            guard let self else { return }
            let module: AssessmentsOverViewViewModel.Module = type == .quiz ? .quizzes : .assignments
            state.assessmentLoadingIndexPath = nil
            state.routeSubject = .showAssessment(status: .closed, module: module, assessmentID: assessmentID, details: assessmentDetails)
        }
        assessmentsViewModel.showQuizAlert = { [weak self] error in
            self?.state.error = error
        }
    }

    private func handleDetailsSelection(at indexPath: IndexPath) {
        let attachments = attachmentsOfLessons(for: indexPath.section)
        guard indexPath.row < attachments.count else { return }
        handleItemSelection(attachments[indexPath.row], at: indexPath)
    }

    private func handleMaterialsSelection(at indexPath: IndexPath) {
        guard let domainItem = state.materialsDomain?.item(at: indexPath) else { return }
        handleItemSelection(domainItem, at: indexPath)
    }

    private func handleItemSelection(_ item: MaterialItemProtocol, at indexPath: IndexPath) {
        switch item.payload {
        case .assessment(let assessment):
            state.activeSubscreen = assessment.type == .quiz ? .quiz : .exercise
            state.selectedAssessmentSection = indexPath.section
            state.assessmentLoadingIndexPath = indexPath
            routeAssessment(assessment)

        case .video(let video):
            guard !video.locked else { state.error = video.lockMessage; return }
            state.routeSubject = .didSelectVideo(video, hideViews: state.hideViews)

        case .attachment(let document):
            state.activeSubscreen = .file
            state.routeSubject = .didSelectDocument(document)
        }
    }

    private func routeAssessment(_ assessment: AssessmentDomain) {
        switch assessment.status {
        case .open where assessment.type == .quiz:
            state.assessmentLoadingIndexPath = nil
            state.routeSubject = .confirmQuiz(assessment)
        case .open:
            assessmentsViewModel.startAssessment(with: assessment)
        case .closed:
            assessmentsViewModel.assessmentResults(for: assessment) {}
        }
    }
}
