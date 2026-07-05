// Copyright © 2026 Pharos Solutions. All rights reserved.

import Foundation

class BaseCoursesViewModel {
    var apiProvider: ApiProvider

    var page: Int = 1
    var courses: [SubjectCourses] = []
    private(set) var subjects: [Subject] = []
    var emptyStateType: EmptyStateType = .loading
    var selectedSubject: Subject?
    var selectedSubjectIndexPath: IndexPath = IndexPath(row: 0, section: 0)
    private(set) var mode: HomeMode = .relatedCourses

    /// Subclasses override to return `true` for "My Courses" API requests.
    var isMyCourses: Bool { return false }

    init(apiProvider: ApiProvider = .shared) {
        self.apiProvider = apiProvider
    }

    func fetchUserProfile(completion: (() -> Void)? = nil) {
        let userId = String(User.shared.id ?? 0)
        apiProvider.request(
            .profile(.fetchProfile(.init(id: userId))),
            decodeTo: StudentModel.self
        ) { [weak self] result in
            switch result {
            case .success(let user):
                self?.setUserData(user)
            case .failure:
                return
            }
            completion?()
        }
    }

    func loadCourses(completion: @escaping () -> Void) {
        fetchCoursesForCurrentMode(completion: completion)
    }

    func fetchCoursesForCurrentMode(completion: @escaping () -> Void) {
        let requestModel = CoursesRequestModel(
            type: mode,
            myCourses: isMyCourses,
            subjectID: selectedSubject?.id,
            page: page,
            locale: Language.currentLanguage.rawValue
        )

        let endpoint: Endpoint = {
            switch mode {
            case .relatedCourses:
                return .home(.relatedCourses(requestModel))
            case .exploreMore:
                return .home(.exploreMoreCourses(requestModel))
            }
        }()

        apiProvider.request(endpoint, decodeTo: CoursesResponse.self) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let coursesResponse):
                self.parseCoursesResponse(coursesResponse)
                self.page += 1
                self.updateEmptyState()
            case .failure:
                return
            }
            completion()
        }
    }

    func changeMode(to newMode: HomeMode) {
        mode = newMode
        selectedSubject = nil
        resetPagination()
    }

    func selectSubject(_ subject: Subject) {
        selectedSubject = subject
        resetPagination()
    }

    func resetPagination() {
        page = 1
        courses.removeAll()
    }

    func parseCoursesResponse(_ coursesResponse: CoursesResponse) {
        if let subjects = coursesResponse.subjects {
            self.subjects = subjects
        }
        if page == 1 {
            courses.removeAll()
        }
        if let exploreCourses = coursesResponse.teachersCourses {
            courses.append(contentsOf: exploreCourses)
        }
    }

    /// Subclasses override to set the appropriate empty state type.
    func updateEmptyState() {
        // Default: no action. Subclasses provide context-specific logic.
    }

    private func setUserData(_ user: StudentModel) {
        User.shared.setUserData(user: user.student)
    }
}
