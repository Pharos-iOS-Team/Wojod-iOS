// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation
import Moya

class LogoutApiClient {
    let logoutProvider = MoyaProvider<LogoutTarget>()

    func logout(deviceId: String, completionHandler: @escaping (Response?, MoyaError?) -> Void) {
        logoutProvider.request(.logout(deviceId: deviceId)) { result in
            switch result {
            case .success(let response):
                completionHandler(response, nil)
            case .failure(let error):
                completionHandler(nil, error)
            }
        }
    }
}
