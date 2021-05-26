// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation
import Moya

class CourseDetailsApiClient {
    let courseDetailsProvider = MoyaProvider<CourseDetailsTarget>()

    func loadLessons(courseID: Int, completion: @escaping (Response?, MoyaError?) -> Void) {
        courseDetailsProvider.request(.loadLessons(courseID: courseID)) { result in
            switch result {
            case .success(let response):
                completion(response, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
}
