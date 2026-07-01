// Copyright © 2026 Pharos Solutions. All rights reserved.

import Foundation

final class HomeViewModel: BaseCoursesViewModel {
    var searchText: String = ""
    var advertisements: [Advertisement] = []

    var isInSearchMode: Bool {
        return searchText.isValid
    }

    override func loadCourses(completion: @escaping () -> Void) {
        if isInSearchMode {
            searchCourses(completion: completion)
        } else {
            fetchCoursesForCurrentMode(completion: completion)
        }
    }

    private func searchCourses(completion: @escaping () -> Void) {
        apiProvider.request(
            .home(.searchCourses(.init(value: searchText))),
            decodeTo: CoursesResponse.self
        ) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let resultCourses):
                self.courses = resultCourses.teachersCourses ?? []
                self.updateEmptyState()
                completion()
            case .failure:
                completion()
            }
        }
    }

    func loadAdvertisements(completion: @escaping ([Advertisement]) -> Void) {
        apiProvider.request(.home(.loadAdvertisements), decodeTo: Advertisements.self) { [weak self] result in
            switch result {
            case .success(let advertisements):
                self?.advertisements = advertisements.advertisements ?? []
                completion(advertisements.advertisements ?? [])
            case .failure:
                completion([])
            }
        }
    }

    func updateSearchText(_ text: String) {
        searchText = text
        if !text.isValid {
            page = 1
        }
    }

    override func updateEmptyState() {
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
}
