// Copyright © 2026 Pharos Solutions. All rights reserved.

import Dependencies
import Foundation

protocol CoursesRepositoryProtocol {
    func fetchCourses(
        mode: HomeMode,
        isMyCourses: Bool,
        subjectID: Int?,
        page: Int
    ) async throws -> CoursesResponse

    func searchCourses(query: String) async throws -> CoursesResponse
}

final class CoursesRepository: CoursesRepositoryProtocol {
    @Dependency(\.apiProvider)
    var apiProvider: ApiProvider

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
