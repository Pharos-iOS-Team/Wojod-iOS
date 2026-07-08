// Copyright © 2026 Pharos Solutions. All rights reserved.

import Foundation

final class HomeViewModel: CourseListViewModeling, CourseSearching {
    let isMyCourses: Bool = false

    var courses: [SubjectCourses] = []
    var subjects: [Subject] = []
    var selectedSubjectIndexPath: IndexPath = IndexPath(row: 0, section: 0)
    var selectedSubject: Subject?
    var mode: HomeMode = .relatedCourses
    var emptyStateType: EmptyStateType = .loading
    var searchText: String = ""
    var advertisements: [Advertisement] = []
    var hasCompletedInitialLoad: Bool { loadedModes.contains(mode) }

    private var loadedModes: Set<HomeMode> = []
    private var coursesCache: [HomeMode: [SubjectCourses]] = [:]

    private lazy var paginator = Paginator<SubjectCourses> { [weak self] page in
        guard let self = self else { return [] }
        let response = try await self.coursesRepository.fetchCourses(
            mode: self.mode,
            isMyCourses: false,
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
    private let advertisementsRepository: AdvertisementsRepositoryProtocol

    init(
        coursesRepository: CoursesRepository = CoursesRepository(),
        userProfileRepository: UserProfileRepository = UserProfileRepository(),
        advertisementsRepository: AdvertisementsRepository = AdvertisementsRepository()
    ) {
        self.coursesRepository = coursesRepository
        self.userProfileRepository = userProfileRepository
        self.advertisementsRepository = advertisementsRepository
    }

    func fetchUserProfile() async throws {
        let studentModel = try await userProfileRepository.fetchUserProfile()
        User.shared.setUserData(user: studentModel)
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
        if User.shared.organizations.isEmpty {
            emptyStateType = .noOrganizations
        } else if isInSearchMode {
            emptyStateType = .emptySearch
        } else {
            switch mode {
            case .relatedCourses:
                emptyStateType = .noRelatedCourses
            case .exploreMore:
                emptyStateType = .noExploreMoreCourses
            }
        }
    }

    func applyFilterResults(courses: CoursesResponse?) {
        self.courses = courses?.teachersCourses ?? []
        updateEmptyState()
    }

    func loadAdvertisements() async {
        do {
            advertisements = try await advertisementsRepository.loadAdvertisements()
        } catch {
            advertisements = []
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
