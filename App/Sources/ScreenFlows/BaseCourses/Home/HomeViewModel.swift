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

    private lazy var paginator = Paginator<SubjectCourses> { [weak self] page, completion in
        guard let self = self else {
            completion(.success([]))
            return
        }
        self.coursesService.fetchCourses(
            mode: self.mode,
            isMyCourses: false,
            subjectID: self.selectedSubject?.id,
            page: page
        ) { result in
            switch result {
            case .success(let response):
                if let subjects = response.subjects {
                    self.subjects = subjects
                }
                completion(.success(response.teachersCourses ?? []))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    private let coursesService: CoursesServicing
    private let userProfileService: UserProfileServicing
    private let advertisementsService: AdvertisementsServicing

    init(
        coursesService: CoursesServicing = CoursesService(),
        userProfileService: UserProfileServicing = UserProfileService(),
        advertisementsService: AdvertisementsServicing = AdvertisementsService()
    ) {
        self.coursesService = coursesService
        self.userProfileService = userProfileService
        self.advertisementsService = advertisementsService
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

    func loadAdvertisements(completion: @escaping ([Advertisement]) -> Void) {
        advertisementsService.loadAdvertisements { [weak self] result in
            switch result {
            case .success(let advertisements):
                self?.advertisements = advertisements.advertisements ?? []
                completion(advertisements.advertisements ?? [])
            case .failure:
                completion([])
            }
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
        coursesService.searchCourses(query: searchText) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let resultCourses):
                self.courses = resultCourses.teachersCourses ?? []
                self.updateEmptyState()
            case .failure:
                break
            }
            completion()
        }
    }
}
