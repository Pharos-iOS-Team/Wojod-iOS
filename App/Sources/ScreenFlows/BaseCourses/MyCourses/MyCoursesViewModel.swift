// Copyright © 2026 Pharos Solutions. All rights reserved.

import Foundation

final class MyCoursesViewModel: BaseCoursesViewModel {
    override var isMyCourses: Bool { return true }

    func searchCourses(value: String, completion: @escaping () -> Void) {
        apiProvider.request(
            .home(.searchCourses(.init(value: value))),
            decodeTo: CoursesResponse.self
        ) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let resultCourses):
                self.courses = resultCourses.teachersCourses ?? []
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
