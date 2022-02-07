// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation
import Moya

struct CoursesRequestModel {
    let type: HomeMode
    let isMyCourses: Bool
    let subjectID: Int?
    let page: Int
    let limit: Int = 10
}

class HomeApiClient {
    let homeProvider = MoyaProvider<HomeTarget>()

    func loadSubjects(batchID: Int, completion: @escaping (Response?, MoyaError?) -> Void) {
        homeProvider.request(.loadSubjects(batchID: batchID)) { result in
            switch result {
            case .success(let response):
                completion(response, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }

    func loadCourses(requestModel: CoursesRequestModel, completion: @escaping (Response?, MoyaError?) -> Void) {
        switch requestModel.type {
        case .relatedCourses:
            loadRelatedCourses(requestModel: requestModel, completion: completion)
        case .exploreMore:
            loadExploreMoreCourses(requestModel: requestModel, completion: completion)
        }
    }

    private func loadRelatedCourses(requestModel: CoursesRequestModel, completion: @escaping (Response?, MoyaError?) -> Void) {
        homeProvider.request(.relatedCourses(requestModel: requestModel)) { result in
            switch result {
            case .success(let response):
                completion(response, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }

    private func loadExploreMoreCourses(requestModel: CoursesRequestModel, completion: @escaping (Response?, MoyaError?) -> Void) {
        homeProvider.request(.exploreMoreCourses(requestModel: requestModel)) { result in
            switch result {
            case .success(let response):
                completion(response, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }

    func searchCourses(value: String, completion: @escaping (Response?, MoyaError?) -> Void) {
        homeProvider.request(.searchCourses(value: value)) { result in
            switch result {
            case .success(let response):
                completion(response, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }

    func loadAds(completion: @escaping (Response?, Error?) -> Void) {
        homeProvider.request(.loadAdvertisements) { result in
            switch result {
            case .success(let response):
                completion(response, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
}
