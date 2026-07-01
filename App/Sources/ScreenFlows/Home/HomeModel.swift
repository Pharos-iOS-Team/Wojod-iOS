// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

class HomeModel {
    func loadSubjects(batchID: Int, completion: @escaping (Swift.Result<Subjects, Error>) -> Void) {
        ApiProvider.shared.request(.home(.loadSubjects(batchID: batchID)), decodeTo: Subjects.self, completion: completion)
    }

    func loadCourses(requestModel: CoursesRequestModel, completion: @escaping (Swift.Result<CoursesResponse, Error>) -> Void) {
        let endpoint: Endpoint = {
            switch requestModel.type {
            case .relatedCourses:
                return .home(.relatedCourses(requestModel))
            case .exploreMore:
                return .home(.exploreMoreCourses(requestModel))
            }
        }()
        ApiProvider.shared.request(endpoint, decodeTo: CoursesResponse.self, completion: completion)
    }

    func searchCourses(value: String, completion: @escaping (Swift.Result<CoursesResponse, Error>) -> Void) {
        ApiProvider.shared.request(.home(.searchCourses(.init(value: value))), decodeTo: CoursesResponse.self, completion: completion)
    }

    func loadAds(completion: @escaping (Swift.Result<Advertisements, Error>) -> Void) {
        ApiProvider.shared.request(.home(.loadAdvertisements), decodeTo: Advertisements.self, completion: completion)
    }

    func fetchUserProfile(id: Int, completionHandler: @escaping (Swift.Result<StudentModel, Error>) -> Void) {
        ApiProvider.shared.request(.profile(.fetchProfile(.init(id: String(User.shared.id ?? 0)))), decodeTo: StudentModel.self, completion: completionHandler)
    }
}
