// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation
import Moya

class ForgotPasswordApiClient {
    let forgotPasswordProvider = MoyaProvider<ForgotPasswordTarget>()

    func sendMobileNumber(mobileNumber: String, completionHandler: @escaping (Response?, MoyaError?) -> Void) {
        forgotPasswordProvider.request(.sendMobileNumber(mobileNumber: mobileNumber)) { result in
            switch result {
            case .success(let response):
                completionHandler(response, nil)
            case .failure(let error):
                completionHandler(nil, error)
            }
        }
    }
}
