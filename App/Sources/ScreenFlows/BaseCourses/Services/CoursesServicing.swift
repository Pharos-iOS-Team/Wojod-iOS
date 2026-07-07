// Copyright © 2026 Pharos Solutions. All rights reserved.

import Foundation

protocol CoursesServicing {
    func fetchCourses(
        mode: HomeMode,
        isMyCourses: Bool,
        subjectID: Int?,
        page: Int,
        completion: @escaping (Result<CoursesResponse, Error>) -> Void
    )

    func searchCourses(
        query: String,
        completion: @escaping (Result<CoursesResponse, Error>) -> Void
    )
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
        page: Int,
        completion: @escaping (Result<CoursesResponse, Error>) -> Void
    ) {
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

        apiProvider.request(endpoint, decodeTo: CoursesResponse.self) { result in
            completion(result)
        }
    }

    func searchCourses(
        query: String,
        completion: @escaping (Result<CoursesResponse, Error>) -> Void
    ) {
        apiProvider.request(
            .home(.searchCourses(.init(value: query))),
            decodeTo: CoursesResponse.self
        ) { result in
            completion(result)
        }
    }
}
