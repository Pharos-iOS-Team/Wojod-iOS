// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation
import Moya

class SetPasswordApiClient {
    let provider = MoyaProvider<SetPasswordTarget>()

    func setPassword(request: SetPasswordRequest, completionHandler: @escaping (Response?, MoyaError?) -> Void) {
        provider.request(.setPassword(request: request)) { result in
            switch result {
            case .success(let response):
                completionHandler(response, nil)
            case .failure(let error):
                completionHandler(nil, error)
            }
        }
    }
}
