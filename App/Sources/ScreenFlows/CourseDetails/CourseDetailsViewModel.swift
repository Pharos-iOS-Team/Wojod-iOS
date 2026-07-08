// Copyright © 2021 Pharos Solutions. All rights reserved.

import Dependencies
import Foundation
import SwiftyUserDefaults

class CourseDetailsViewModel: NSObject {
    // MARK: - Dependencies

    @Dependency(\.apiProvider)
    var apiProvider: ApiProvider

    // MARK: - Child ViewModels

    let quizzesViewModel: AssessmentsOverViewViewModel
    let assignmentsViewModel: AssessmentsOverViewViewModel

    // MARK: - State

    var course: Course?
    var hideViews: Bool = false
    var teacherName: String?
    var teacherID: Int?
    var courseState: CourseState = .normal
    var activeScreen: ActiveScreen = .details
    var lessonsList: [Lesson] = []
    var lessonNumbersList: [Int]?
    var reviewsList: [Review] = []
    var materials: Materials?
    var attachmentsOfLessons: [Int: LessonAttachmentsModel] = [:]
    var expandedSections: [Int] = []
    var doesLessonContainAttachments: [Int: Bool] = [:]
    var selectedAssessment: Assessment?
    var selectedAssessmentSection: Int?
    var isLoadingTab: Bool = false

    func clearTabData() {
        switch activeScreen {
        case .details:
            lessonsList = []
            lessonNumbersList = nil
            attachmentsOfLessons = [:]
            doesLessonContainAttachments = [:]
            expandedSections = []
        case .materials:
            materials = nil
        case .reviews:
            reviewsList = []
        }
    }

    // MARK: - Output Bindings

    var onStateUpdated: (() -> Void)?
    var onLoadingChanged: ((Bool) -> Void)?
    var onError: ((String) -> Void)?
    var onShowQuizAlert: ((Assessment) -> Void)?
    var onOpenAssessment: ((AssessmentsOverViewViewModel.Module, Int?, AssessmentDetails?) -> Void)?
    var onShowAssessmentResults: ((AssessmentsOverViewViewModel.Module, Int?, AssessmentDetails?) -> Void)?

    // MARK: - Computed UI Properties

    var isContactInfoAvailable: Bool {
        course?.contactUsInfo?.isValid ?? false
    }

    var shouldShowQRButton: Bool {
        (course?.qrCodeEnabled ?? false) && courseState == .normal
    }

    var coursePrice: String {
        guard !isTestingAccount() else { return "" }
        if course?.price == nil || course?.price?.isEmpty ?? true {
            return L10n.Home.Course.returnToTeacher
        } else {
            return "\(L10n.Home.Course.price) \(course?.price ?? "")"
        }
    }

    // MARK: - Init

    override init() {
        self.quizzesViewModel = AssessmentsOverViewViewModel(module: .quizzes)
        self.assignmentsViewModel = AssessmentsOverViewViewModel(module: .assignments)
        super.init()
        bindAssessmentHandlers()
    }

    // MARK: - Data Loading

    func loadCourseDetails() async {
        guard let courseID = course?.id else { return }
        let courseResponse = await loadCourse(courseID: "\(courseID)")
        if let courseResponse {
            course = courseResponse.course
            hideViews = courseResponse.hideViews ?? false
            courseState = course?.parsedReservationState ?? .normal
        }
    }

    func loadCourseLessons() async {
        guard let courseID = course?.id else { return }
        let lessons = await loadLessons(courseID: courseID)
        if let lessons {
            lessonsList = lessons
            generateLessonsNumbersList()
        }
    }

    func handleRefreshingAccordingToOpenedTab() async {
        guard let courseID = course?.id else { return }
        switch activeScreen {
        case .details:
            await loadCourseLessonsWithDetails()
        case .materials:
            let materials = await loadMaterials(courseID: courseID)
            self.materials = materials
        case .reviews:
            let reviews = await loadReviews(courseID: courseID)
            reviewsList = reviews ?? []
        }
    }

    // MARK: - Lessons

    func generateLessonsNumbersList() {
        guard lessonsList.count >= 1 else { return }
        lessonNumbersList = Array(1 ... lessonsList.count)
    }

    func numberOfRowsForLesson(section: Int) -> Int {
        guard expandedSections.contains(section) else { return 0 }
        let attachments = attachmentsOfLessons[section]
        let documentsCount = attachments?.documents?.count ?? 0
        let assignmentsCount = attachments?.assignments?.count ?? 0
        let videosCount = attachments?.videos?.count ?? 0
        let quizzesCount = attachments?.quizzes?.count ?? 0
        return documentsCount + assignmentsCount + videosCount + quizzesCount
    }

    func flatAttachments(for section: Int) -> [Any] {
        var result: [Any] = []
        let attachments = attachmentsOfLessons[section]
        if let assignments = attachments?.assignments { result.append(contentsOf: assignments) }
        if let quizzes = attachments?.quizzes { result.append(contentsOf: quizzes) }
        if let videos = attachments?.videos { result.append(contentsOf: videos) }
        if let documents = attachments?.documents { result.append(contentsOf: documents) }
        return result
    }

    func toggleSectionExpansion(_ section: Int, completion: @escaping () -> Void) {
        guard !lessonsList[section].locked else {
            let message = lessonsList[section].lockMessage
            onError?(message)
            return
        }
        guard course?.parsedReservationState == .booked else { return }
        if expandedSections.contains(section) {
            expandedSections.removeAll { $0 == section }
        } else {
            expandedSections.append(section)
        }
        completion()
    }

    func prefetchAllLessonDetails() async {
        guard course?.parsedReservationState == .booked else { return }
        await fetchAllLessonDetailsConcurrently()
    }

    private func fetchAllLessonDetailsConcurrently() async {
        await withTaskGroup(of: (Int, LessonAttachmentsModel?).self) { group in
            for (section, lesson) in lessonsList.enumerated() {
                group.addTask { [weak self] in
                    guard let self else { return (section, nil) }
                    let attachmentsModel = await self.loadAttachmentsOfLesson(lessonID: lesson.id)
                    return (section, attachmentsModel)
                }
            }
            for await (section, attachmentsModel) in group {
                guard let attachmentsModel else { continue }
                let isEmpty = (attachmentsModel.assignments?.isEmpty ?? true)
                    && (attachmentsModel.documents?.isEmpty ?? true)
                    && (attachmentsModel.quizzes?.isEmpty ?? true)
                    && (attachmentsModel.videos?.isEmpty ?? true)
                await MainActor.run {
                    self.attachmentsOfLessons[section] = attachmentsModel
                    self.doesLessonContainAttachments[section] = !isEmpty
                }
            }
        }
    }

    func loadCourseLessonsWithDetails() async {
        await loadCourseLessons()
        await prefetchAllLessonDetails()
    }

    // MARK: - Booking

    func bookCourse(qrCode: String?) async throws -> BookingCourseResponseModel {
        guard let courseID = course?.id else { throw WJError(type: .parsingError, message: "") }
        return try await apiProvider.request(
            .courseDetails(.bookCourse(
                courseID: courseID,
                requestModel: BookCourseRequestModel(code: qrCode)
            )),
            decodeTo: BookingCourseResponseModel.self
        )
    }

    func handleBookingSuccess(bookingResponse: BookingCourseResponseModel?, isQR: Bool) -> Bool {
        if !isQR {
            courseState = .pending
        }
        return !isTestingAccount()
    }

    // MARK: - Assessments

    func startAssessment(for type: AssessmentType, at indexPath: IndexPath, completion: @escaping () -> Void) {
        if activeScreen == .materials {
            guard let assessment = type == .quiz
                ? quizzesViewModel.assessments[safe: indexPath.row]
                : assignmentsViewModel.assessments[safe: indexPath.row]
            else { return }
            switch assessment.mappedType {
            case .quiz:
                onShowQuizAlert?(assessment)
                completion()
            case .assignment:
                assignmentsViewModel.startAssessment(with: assessment) { completion() }
            }
        } else {
            let attachments = flatAttachments(for: indexPath.section)
            let assessment = attachments[safe: indexPath.row]
            if let assignment = assessment as? Assessment, assignment.mappedType == .assignment {
                assignmentsViewModel.startAssessment(with: assignment) { completion() }
            } else if let quiz = assessment as? Assessment, quiz.mappedType == .quiz {
                onShowQuizAlert?(quiz)
                completion()
            }
        }
    }

    func startAssessmentFromAlert(with assessment: Assessment) {
        if assessment.mappedType == .quiz {
            quizzesViewModel.startAssessment(with: assessment)
        } else {
            assignmentsViewModel.startAssessment(with: assessment)
        }
    }

    func showResultForAssessment(type: AssessmentType, at indexPath: IndexPath, completion: @escaping () -> Void) {
        if activeScreen == .materials {
            if type == .quiz {
                quizzesViewModel.assessmentResults(for: quizzesViewModel.assessments[safe: indexPath.row]) { completion() }
            } else {
                assignmentsViewModel.assessmentResults(for: assignmentsViewModel.assessments[safe: indexPath.row]) { completion() }
            }
        } else {
            let attachments = flatAttachments(for: indexPath.section)
            let assessment = attachments[safe: indexPath.row] as? Assessment
            if type == .quiz {
                quizzesViewModel.assessmentResults(for: assessment) { completion() }
            } else {
                assignmentsViewModel.assessmentResults(for: assessment) { completion() }
            }
        }
    }

    private func bindAssessmentHandlers() {
        quizzesViewModel.startAssessmentHandler = { [weak self] assessmentID, assessmentDetails, _ in
            self?.onOpenAssessment?(.quizzes, assessmentID, assessmentDetails)
        }
        assignmentsViewModel.startAssessmentHandler = { [weak self] assessmentID, assessmentDetails, _ in
            self?.onOpenAssessment?(.assignments, assessmentID, assessmentDetails)
        }
        quizzesViewModel.assessmentResultsHandler = { [weak self] assessmentID, assessmentDetails, type in
            let module: AssessmentsOverViewViewModel.Module = type == .quiz ? .quizzes : .assignments
            self?.onShowAssessmentResults?(module, assessmentID, assessmentDetails)
        }
        assignmentsViewModel.assessmentResultsHandler = { [weak self] assessmentID, assessmentDetails, _ in
            self?.onShowAssessmentResults?(.assignments, assessmentID, assessmentDetails)
        }
        quizzesViewModel.showQuizAlert = { [weak self] error in
            self?.onError?(error)
        }
    }

    // MARK: - Network

    func loadLessons(courseID: Int) async -> [Lesson]? {
        do {
            let lessons = try await apiProvider.request(
                .courseDetails(.loadLessons(courseID: courseID)),
                decodeTo: ApiResponse<[Lesson]>.self
            )
            return lessons.data
        } catch {
            await MainActor.run { self.onError?(error.localizedDescription) }
            return nil
        }
    }

    func loadReviews(courseID: Int) async -> [Review]? {
        do {
            let reviews = try await apiProvider.request(
                .courseDetails(.loadReviews(courseID: courseID)),
                decodeTo: ApiResponse<[Review]>.self
            )
            return reviews.data
        } catch {
            await MainActor.run { self.onError?(error.localizedDescription) }
            return nil
        }
    }

    func loadAttachmentsOfLesson(lessonID: Int) async -> LessonAttachmentsModel? {
        do {
            return try await apiProvider.request(
                .courseDetails(.loadAttachmentsOfLesson(lessonID: lessonID)),
                decodeTo: LessonAttachmentsModel.self
            )
        } catch {
            await MainActor.run { self.onError?(error.localizedDescription) }
            return nil
        }
    }

    func cancelBookingCourse(courseID: Int) async -> Bool {
        do {
            _ = try await apiProvider.request(.courseDetails(.cancelBookingCourse(courseID: courseID)))
            return true
        } catch {
            return false
        }
    }

    func sendReview(courseID: Int, courseReview: CourseReview) async -> Bool {
        do {
            _ = try await apiProvider.request(.courseDetails(.sendReview(courseID: courseID, courseReview: courseReview)))
            return true
        } catch {
            return false
        }
    }

    func loadMaterials(courseID: Int) async -> Materials? {
        do {
            var materials = try await apiProvider.request(
                .courseDetails(.loadMaterials(courseID: courseID)),
                decodeTo: Materials.self
            )
            materials.sort()
            return materials
        } catch {
            await MainActor.run { self.onError?(error.localizedDescription) }
            return nil
        }
    }

    func loadCourse(courseID: String) async -> CourseDetailsResponse? {
        do {
            return try await apiProvider.request(
                .courseDetails(.loadCourse(courseID: courseID)),
                decodeTo: CourseDetailsResponse.self
            )
        } catch {
            await MainActor.run { self.onError?(error.localizedDescription) }
            return nil
        }
    }

    func fetchVideoDetails(videoId: String) async -> EncryptedVideoResponse? {
        do {
            return try await apiProvider.request(
                .courseDetails(.fetchVideo(videoId: videoId)),
                decodeTo: EncryptedVideoResponse.self
            )
        } catch {
            return nil
        }
    }

    func updateVideo(videoId: String, updateObject: UpdateObject) async {
        do {
            _ = try await apiProvider.request(
                .courseDetails(.updateVideo(videoId: videoId, updateObject: updateObject))
            )
        } catch {
            await MainActor.run { self.onError?(error.localizedDescription) }
        }
    }

    func isGuestModeEnabled() -> Bool {
        return Defaults[\.isGuestModeEnabled]
    }
}
