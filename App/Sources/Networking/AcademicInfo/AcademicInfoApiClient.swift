// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation
import Moya

class AcademicInfoApiClient {
    let academicInfoProvider = MoyaProvider<AcademicInfoTarget>()

    func fetchEducationalTypes(completionHandler: @escaping (Response?, MoyaError?) -> Void) {
        academicInfoProvider.request(
            .getEducationalTypes(educationLevel: String(User.shared.educationLevel ?? 0),
                educationType: String(User.shared.educationType ?? 0))) { result in
            switch result {
            case .success(let response):
                completionHandler(response, nil)
            case .failure(let error):
                completionHandler(nil, error)
            }
        }
    }

    func fetchDivisions(completionHandler: @escaping (Response?, MoyaError?) -> Void) {
        academicInfoProvider.request(
            .getDivisions(educationLevel: String(User.shared.educationLevel ?? 0), educationType: String(User.shared.educationType ?? 0))) { result in
            switch result {
            case .success(let response):
                completionHandler(response, nil)
            case .failure(let error):
                completionHandler(nil, error)
            }
        }
    }

    func fetchBatches(id: String, completionHandler: @escaping (Response?, MoyaError?) -> Void) {
        academicInfoProvider.request(.getBatches(id: id)) { result in
            switch result {
            case .success(let response):
                completionHandler(response, nil)
            case .failure(let error):
                completionHandler(nil, error)
            }
        }
    }

    func fetchSpecializations(id: String, completionHandler: @escaping (Response?, MoyaError?) -> Void) {
        academicInfoProvider.request(.getSpecializations(id: id)) { result in
            switch result {
            case .success(let response):
                completionHandler(response, nil)
            case .failure(let error):
                completionHandler(nil, error)
            }
        }
    }
}
