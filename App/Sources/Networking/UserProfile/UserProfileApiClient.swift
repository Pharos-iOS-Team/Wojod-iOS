// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation
import Moya

class UserProfileApiClient {
    let userProfileProvider = MoyaProvider<UserProfileTarget>()

    func getUserProfile(id: Int, completionHandler: @escaping (Response?, MoyaError?) -> Void) {
        userProfileProvider.request(.getUserProfile(id: id)) { result in
            switch result {
            case .success(let response):
                completionHandler(response, nil)
            case .failure(let error):
                completionHandler(nil, error)
            }
        }
    }
}
