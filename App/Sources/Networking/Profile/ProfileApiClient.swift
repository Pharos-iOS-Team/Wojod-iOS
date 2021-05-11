// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation
import Moya

class ProfileApiClient {
    let profileProvider = MoyaProvider<ProfileTarget>()

    func fetchProfile(id: String, completionHandler: @escaping (Response?, MoyaError?) -> Void) {
        profileProvider.request(.getProfile(id: id)) { result in
            switch result {
            case .success(let response):
                completionHandler(response, nil)
            case .failure(let error):
                completionHandler(nil, error)
            }
        }
    }

    func editProfile(id: String, profile: Profile, completionHandler: @escaping(Response?, MoyaError?) -> Void) {
        profileProvider.request(.editProfile(id: id, profile: profile)) { result in
            switch result {
            case .success(let response):
                completionHandler(response, nil)
            case .failure(let error):
                completionHandler(nil, error)
            }
        }
    }
}
