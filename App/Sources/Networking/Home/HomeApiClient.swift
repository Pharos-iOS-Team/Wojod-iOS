// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation
import Moya

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

    func loadRelatedCourses(
        isMyCourses: Bool,
        subjectID: Int?,
        page: Int,
        limit: Int,
        completion: @escaping (Response?, MoyaError?) -> Void
    ) {
        homeProvider.request(.loadRelatedCourses(isMyCourses: isMyCourses, subjectID: subjectID, page: page, limit: limit)) { result in
            switch result {
            case .success(let response):
                completion(response, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }

    // swiftlint:disable:next function_parameter_count
    func loadRelatedCoursesForTeacher(
        teacherID: Int,
        isMyCourses: Bool,
        subjectID: Int,
        page: Int,
        limit: Int,
        completion: @escaping (Response?, MoyaError?) -> Void
    ) { homeProvider.request(.loadRelatedCoursesForTeacher(teacherID: teacherID, subjectID: subjectID, isMyCourses: isMyCourses, page: page, limit: limit)) { result in
            switch result {
            case .success(let response):
                completion(response, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }

    func loadExploreMoreCourses(isMyCourses: Bool, page: Int, limit: Int, completion: @escaping (Response?, MoyaError?) -> Void) {
        homeProvider.request(.loadExploreMoreCourses(isMyCourses: isMyCourses, page: page, limit: limit)) { result in
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
}
