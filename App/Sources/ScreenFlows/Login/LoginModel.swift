// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation
import Moya

class LoginModel: ModelDecodable {
    private let apiClient = LoginApiClient()

    func login(mobileNumber: String, password: String, completionHandler: @escaping (Result) -> Void) {
        let loginRequestModel = LoginRequestModel(mobileNumber: mobileNumber, password: password)
        apiClient.login(loginRequestModel: loginRequestModel) { response, error in
            if let response = response {
                if response.statusCode < 300 {
                    self.cacheAccessToken(token: response.response?.headers["access-token"])
                    self.decode(modelType: LoginApiResponseModel.self, from: response) { result in
                        completionHandler(result)
                    }
                } else {
                    self.decodeError(response: response, completionHandler: completionHandler)
                }
            } else if let error = error {
                completionHandler(.failure(WJError(type: .parsingError, message: error.localizedDescription)))
            }
        }
    }

    private func cacheAccessToken(token: String?) {
        guard let token = token else { return }
        KeychainHandler.shared.saveUserToken(token)
    }
}
