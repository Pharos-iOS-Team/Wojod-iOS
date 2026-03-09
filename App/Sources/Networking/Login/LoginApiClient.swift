// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation
import Moya

class LoginApiClient {
    let loginProvider = MoyaProvider<LoginTarget>()

    func login(loginRequestModel: LoginRequestModel, completionHandler: @escaping (Response?, MoyaError?) -> Void) {
        loginProvider.request(.login(loginRequestModel: loginRequestModel)) { result in
            switch result {
            case .success(let response):
                completionHandler(response, nil)
            case .failure(let error):
                completionHandler(nil, error)
            }
        }
    }

    func guestMode(completionHandler: @escaping (Response?, MoyaError?) -> Void) {
        loginProvider.request(.guestMode(appName: AppEnvironment.appName.guestModeKey)) { result in
            switch result {
            case .success(let response):
                completionHandler(response, nil)
            case .failure(let error):
                completionHandler(nil, error)
            }
        }
    }
}
