// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation
import SwiftyUserDefaults

class CourseDetailsViewModel: NSObject {
    // MARK: - Dependencies

    let apiProvider: ApiProvider

    // MARK: - Child ViewModels

    let quizzesViewModel: AssessmentsOverViewViewModel
    let assignmentsViewModel: AssessmentsOverViewViewModel

    // MARK: - State

    var course: Course!
    var hideViews: Bool = false
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
        course.contactUsInfo?.isValid ?? false
    }

    var shouldShowQRButton: Bool {
        (course.qrCodeEnabled ?? false) && courseState == .normal
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

    init(apiProvider: ApiProvider = .shared) {
        self.apiProvider = apiProvider
        self.quizzesViewModel = AssessmentsOverViewViewModel(module: .quizzes)
        self.assignmentsViewModel = AssessmentsOverViewViewModel(module: .assignments)
        super.init()
        bindAssessmentHandlers()
    }

    // MARK: - Data Loading

    func loadCourseDetails(completion: @escaping () -> Void) {
        loadCourse(courseID: "\(course.id)") { [weak self] courseResponse in
            guard let self else { return }
            self.course = courseResponse.course
            self.hideViews = courseResponse.hideViews ?? false
            self.courseState = course.getReservationState()
            completion()
        }
    }

    func loadCourseLessons(completion: @escaping () -> Void) {
        loadLessons(courseID: course.id) { [weak self] lessonsModel in
            guard let self else { return }
            self.lessonsList = lessonsModel.lessons
            self.generateLessonsNumbersList()
            completion()
        }
    }

    func handleRefreshingAccordingToOpenedTab(completion: @escaping () -> Void) {
        switch activeScreen {
        case .details:
            loadCourseLessons { completion() }
        case .materials:
            loadMaterials(courseID: course.id) { [weak self] materials in
                self?.materials = materials
                completion()
            }
        case .reviews:
            loadReviews(courseID: course.id) { [weak self] result in
                self?.reviewsList = result.reviews ?? []
                completion()
            }
        }
    }

    // MARK: - Lessons

    func generateLessonsNumbersList() {
        guard lessonsList.count >= 1 else { return }
        lessonNumbersList = Array(1 ... lessonsList.count)
    }

    func numberOfRowsForLesson(section: Int) -> Int {
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
        guard course?.getReservationState() == .booked else { return }
        if expandedSections.contains(section) {
            expandedSections.removeAll { $0 == section }
            attachmentsOfLessons[section] = nil
            completion()
        } else {
            expandedSections.append(section)
            loadAttachmentsOfLesson(lessonID: lessonsList[section].id) { [weak self] attachmentsModel in
                guard let self else { return }
                self.attachmentsOfLessons[section] = attachmentsModel
                let isEmpty = (attachmentsModel.assignments?.isEmpty ?? true)
                && (attachmentsModel.documents?.isEmpty ?? true)
                && (attachmentsModel.quizzes?.isEmpty ?? true)
                && (attachmentsModel.videos?.isEmpty ?? true)
                self.doesLessonContainAttachments[section] = !isEmpty
                completion()
            }
        }
    }

    func checkAttachmentPresence(section: Int, completion: @escaping () -> Void) {
        guard course?.getReservationState() == .booked else { return }
        loadAttachmentsOfLesson(lessonID: lessonsList[section].id) { [weak self] attachmentsModel in
            guard let self else { return }
            let isEmpty = (attachmentsModel.assignments?.isEmpty ?? true)
            && (attachmentsModel.documents?.isEmpty ?? true)
            && (attachmentsModel.quizzes?.isEmpty ?? true)
            && (attachmentsModel.videos?.isEmpty ?? true)
            self.doesLessonContainAttachments[section] = !isEmpty
            self.attachmentsOfLessons[section] = nil
            completion()
        }
    }

    // MARK: - Booking

    func bookCourse(qrCode: String?, completion: @escaping (BookingCourseResponseModel?, Error?) -> Void) {
        apiProvider.request(
            .courseDetails(.bookCourse(
                courseID: course.id,
                requestModel: BookCourseRequestModel(code: qrCode)
            )),
            decodeTo: BookingCourseResponseModel.self
        ) { result in
            switch result {
            case .success(let bookingResponse):
                completion(bookingResponse, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
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
        quizzesViewModel.showQuizAlet = { [weak self] error in
            self?.onError?(error)
        }
    }

    // MARK: - Network (original methods preserved)

    func loadLessons(courseID: Int, completion: @escaping (LessonsModel) -> Void) {
        apiProvider.request(
            .courseDetails(.loadLessons(courseID: courseID)),
            decodeTo: LessonsModel.self
        ) { result in
            switch result {
            case .success(let lessons):
                completion(lessons)
            case .failure:
                return
            }
        }
    }

    func loadReviews(courseID: Int, completion: @escaping (ReviewsModel) -> Void) {
        apiProvider.request(
            .courseDetails(.loadReviews(courseID: courseID)),
            decodeTo: ReviewsModel.self
        ) { result in
            switch result {
            case .success(let reviews):
                completion(reviews)
            case .failure:
                return
            }
        }
    }

    func loadAttachmentsOfLesson(lessonID: Int, completion: @escaping (LessonAttachmentsModel) -> Void) {
        apiProvider.request(
            .courseDetails(.loadAttachmentsOfLesson(lessonID: lessonID)),
            decodeTo: LessonAttachmentsModel.self
        ) { result in
            switch result {
            case .success(let attachments):
                completion(attachments)
            case .failure:
                return
            }
        }
    }

    func cancelBookingCourse(courseID: Int, completion: @escaping (Bool) -> Void) {
        apiProvider.request(.courseDetails(.cancelBookingCourse(courseID: courseID))) { result in
            switch result {
            case .success:
                completion(true)
            case .failure:
                completion(false)
            }
        }
    }

    func sendReview(courseID: Int, courseReview: CourseReview, completion: @escaping (Bool) -> Void) {
        apiProvider.request(.courseDetails(.sendReview(courseID: courseID, courseReview: courseReview))) { result in
            switch result {
            case .success:
                completion(true)
            case .failure:
                completion(false)
            }
        }
    }

    func loadMaterials(courseID: Int, completion: @escaping (Materials) -> Void) {
        apiProvider.request(
            .courseDetails(.loadMaterials(courseID: courseID)),
            decodeTo: Materials.self
        ) { result in
            switch result {
            case .success(var materials):
                materials.sort()
                completion(materials)
            case .failure:
                return
            }
        }
    }

    func loadCourse(courseID: String, completion: @escaping (CourseDetailsResponse) -> Void) {
        apiProvider.request(
            .courseDetails(.loadCourse(courseID: courseID)),
            decodeTo: CourseDetailsResponse.self
        ) { result in
            switch result {
            case .success(let course):
                completion(course)
            case .failure:
                return
            }
        }
    }

    func fetchVideoDetails(videoId: String, completion: @escaping (EncryptedVideoResponse?) -> Void) {
        apiProvider.request(
            .courseDetails(.fetchVideo(videoId: videoId)),
            decodeTo: EncryptedVideoResponse.self
        ) { result in
            switch result {
            case .success(let encryptedViewResponse):
                completion(encryptedViewResponse)
            case .failure:
                completion(nil)
            }
        }
    }

    func updateVideo(videoId: String, updateObject: UpdateObject) {
        apiProvider.request(
            .courseDetails(.updateVideo(videoId: videoId, updateObject: updateObject))
        ) { result in
            switch result {
            case .success:
                return
            case let .failure(error):
                print(error)
            }
        }
    }

    func isGuestModeEnabled() -> Bool {
        return Defaults[\.isGuestModeEnabled]
    }
}
