// Copyright © 2026 Pharos Solutions. All rights reserved.

import Foundation

final class MyCoursesViewModel: CourseListViewModeling, CourseSearching {
    let isMyCourses: Bool = true

    var courses: [SubjectCourses] = []
    var subjects: [Subject] = []
    var selectedSubjectIndexPath: IndexPath = IndexPath(row: 0, section: 0)
    var selectedSubject: Subject?
    var mode: HomeMode = .relatedCourses
    var emptyStateType: EmptyStateType = .loading
    var searchText: String = ""

    private lazy var paginator = Paginator<SubjectCourses> { [weak self] page, completion in
        guard let self = self else {
            completion(.success([]))
            return
        }
        Task { @MainActor in
            do {
                let response = try await self.coursesService.fetchCourses(
                    mode: self.mode,
                    isMyCourses: true,
                    subjectID: self.selectedSubject?.id,
                    page: page
                )
                if let subjects = response.subjects {
                    self.subjects = subjects
                }
                completion(.success(response.teachersCourses ?? []))
            } catch {
                completion(.failure(error))
            }
        }
    }
    private let coursesService: CoursesServicing
    private let userProfileService: UserProfileServicing

    init(
        coursesService: CoursesServicing = CoursesService(),
        userProfileService: UserProfileServicing = UserProfileService()
    ) {
        self.coursesService = coursesService
        self.userProfileService = userProfileService
    }

    func loadCourses(completion: @escaping () -> Void) {
        if isInSearchMode {
            searchCourses(completion: completion)
        } else {
            fetchCoursesForCurrentMode(completion: completion)
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
        paginator.reset()
        courses.removeAll()
    }

    func updateEmptyState() {
        if User.shared.organizations.isEmpty {
            emptyStateType = .noOrganizations
        } else {
            emptyStateType = .noPurchasedCourses
        }
    }

    // MARK: - Private

    private func fetchCoursesForCurrentMode(completion: @escaping () -> Void) {
        paginator.loadNextPage { [weak self] result in
            guard let self = self else { return }
            if case .success = result {
                self.courses = self.paginator.items
                self.updateEmptyState()
            }
            completion()
        }
    }

    private func searchCourses(completion: @escaping () -> Void) {
        Task { @MainActor [weak self] in
            guard let self = self else { return }
            do {
                let response = try await self.coursesService.searchCourses(query: self.searchText)
                self.courses = response.teachersCourses ?? []
                self.updateEmptyState()
            } catch {}
            completion()
        }
    }
}
