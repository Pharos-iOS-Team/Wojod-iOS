// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation
import Moya

class AvatarApiClient {
    let avatarProvider = MoyaProvider<AvatarTarget>()

    func fetchAvatars(completionHandler: @escaping (Response?, MoyaError?) -> Void) {
        avatarProvider.request(.getAvatars) { result in
            switch result {
            case .success(let response):
                completionHandler(response, nil)
            case .failure(let error):
                completionHandler(nil, error)
            }
        }
    }
}
