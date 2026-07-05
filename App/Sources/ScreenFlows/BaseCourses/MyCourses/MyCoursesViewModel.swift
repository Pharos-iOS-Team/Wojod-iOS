// Copyright © 2026 Pharos Solutions. All rights reserved.

import Foundation

final class MyCoursesViewModel: BaseCoursesViewModel {
    override var isMyCourses: Bool { return true }

    var searchText: String = ""

    var isInSearchMode: Bool {
        return searchText.isValid
    }

    func updateSearchText(_ text: String) {
        searchText = text
        if !text.isValid {
            page = 1
        }
    }

    override func loadCourses(completion: @escaping () -> Void) {
        if isInSearchMode {
            searchCourses(value: searchText, completion: completion)
        } else {
            fetchCoursesForCurrentMode(completion: completion)
        }
    }

    private func searchCourses(value: String, completion: @escaping () -> Void) {
        apiProvider.request(
            .home(.searchCourses(.init(value: value))),
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

    override func updateEmptyState() {
        if User.shared.organizations.isEmpty {
            emptyStateType = .noOrganizations
        } else {
            emptyStateType = .noPurchasedCourses
        }
    }
}
