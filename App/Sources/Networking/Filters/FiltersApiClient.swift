// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation
import Moya

class FiltersApiClient {
    let filtersProvider = MoyaProvider<FiltersTarget>()

    func loadFilteredCourses(isMyCourses: Bool, subjectID: Int, batchID: Int, specializationID: Int?, completion: @escaping (Response?, MoyaError?) -> Void) {
        filtersProvider.request(.loadFilteredCourses(isMyCourses: isMyCourses, subjectID: subjectID, batchID: batchID, specializationID: specializationID)) { result in
            switch result {
            case .success(let response):
                completion(response, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
}
