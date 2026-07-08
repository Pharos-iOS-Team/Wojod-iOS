// Copyright © 2026 Pharos Solutions. All rights reserved.

import Foundation

protocol CoursesServicing {
    func fetchCourses(
        mode: HomeMode,
        isMyCourses: Bool,
        subjectID: Int?,
        page: Int
    ) async throws -> CoursesResponse

    func searchCourses(query: String) async throws -> CoursesResponse
}

final class CoursesService: CoursesServicing {
    private let apiProvider: ApiProvider

    init(apiProvider: ApiProvider = .shared) {
        self.apiProvider = apiProvider
    }

    func fetchCourses(
        mode: HomeMode,
        isMyCourses: Bool,
        subjectID: Int?,
        page: Int
    ) async throws -> CoursesResponse {
        let requestModel = CoursesRequestModel(
            type: mode,
            myCourses: isMyCourses,
            subjectID: subjectID,
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

        return try await apiProvider.request(endpoint, decodeTo: CoursesResponse.self)
    }

    func searchCourses(query: String) async throws -> CoursesResponse {
        try await apiProvider.request(
            .home(.searchCourses(.init(value: query))),
            decodeTo: CoursesResponse.self
        )
    }
}
