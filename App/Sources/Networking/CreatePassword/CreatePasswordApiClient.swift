// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation
import Moya

class CreatePasswordApiClient {
    let createPasswordProvider = MoyaProvider<CreatePasswordTarget>()

    func createPassword(password: Password, completionHandler: @escaping (Response?, MoyaError?) -> Void) {
        createPasswordProvider.request(.createPassword(password: password)) { result in
            switch result {
            case .success(let response):
                completionHandler(response, nil)
            case .failure(let error):
                completionHandler(nil, error)
            }
        }
    }
}
