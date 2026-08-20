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
    private(set) var hasLoadedUserProfile = false
    var hasCompletedInitialLoad: Bool { loadedModes.contains(mode) }

    private var loadedModes: Set<HomeMode> = []
    private var coursesCache: [HomeMode: [SubjectCourses]] = [:]

    private lazy var paginator = Paginator<SubjectCourses> { [weak self] page in
        guard let self = self else { return [] }
        let response = try await self.coursesRepository.fetchCourses(
            mode: self.mode,
            isMyCourses: true,
            subjectID: self.selectedSubject?.id,
            page: page
        )
        if let subjects = response.subjects {
            self.subjects = subjects
        }
        return response.teachersCourses ?? []
    }
    private let coursesRepository: CoursesRepositoryProtocol
    private let userProfileRepository: UserProfileRepositoryProtocol

    init(
        coursesRepository: CoursesRepository = CoursesRepository(),
        userProfileRepository: UserProfileRepository = UserProfileRepository()
    ) {
        self.coursesRepository = coursesRepository
        self.userProfileRepository = userProfileRepository
    }

    func fetchUserProfile() async {
        do {
            let user = try await userProfileRepository.fetchUserProfile()
            User.shared.setUserData(user: user)
            hasLoadedUserProfile = true
        } catch {}
    }

    func loadCourses() async {
        if isInSearchMode {
            await searchCourses()
        } else {
            await fetchCoursesForCurrentMode()
        }
        loadedModes.insert(mode)
    }

    func changeMode(to newMode: HomeMode) {
        coursesCache[mode] = courses
        mode = newMode
        selectedSubject = nil
        paginator.reset()
        if let cachedCourses = coursesCache[newMode], !cachedCourses.isEmpty {
            courses = cachedCourses
            updateEmptyState()
        } else {
            courses.removeAll()
            emptyStateType = .loading
        }
    }

    func selectSubject(_ subject: Subject) {
        selectedSubject = subject
        resetPagination()
    }

    func resetPagination() {
        paginator.reset()
        courses.removeAll()
        emptyStateType = .loading
    }

    func updateEmptyState() {
        if hasLoadedUserProfile && User.shared.organizations.isEmpty {
            emptyStateType = .noOrganizations
        } else {
            emptyStateType = .noPurchasedCourses
        }
    }

    // MARK: - Private

    private func fetchCoursesForCurrentMode() async {
        do {
            _ = try await paginator.loadNextPage()
            courses = paginator.items
            updateEmptyState()
        } catch {
            updateEmptyState()
        }
    }

    private func searchCourses() async {
        do {
            let response = try await coursesRepository.searchCourses(query: searchText)
            courses = response.teachersCourses ?? []
            updateEmptyState()
        } catch {
            updateEmptyState()
        }
    }
}
