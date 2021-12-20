// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation
import Moya

class LogoutApiClient {
    let logoutProvider = MoyaProvider<LogoutTarget>()

    func logout(deviceId: String, completionHandler: @escaping (Response?, MoyaError?) -> Void) {
        logoutProvider.request(.logout(deviceId: deviceId)) { result in
            switch result {
            case let .success(response):
                completionHandler(response, nil)
            case let .failure(error):
                completionHandler(nil, error)
            }
        }
    }
}
