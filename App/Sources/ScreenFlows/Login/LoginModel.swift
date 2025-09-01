// Copyright © 2021 Pharos Solutions. All rights reserved.

import Alamofire
import Foundation
import Moya

class LoginModel: ModelDecodable {
    private let apiClient = LoginApiClient()

    func login(mobileNumber: String, password: String, completionHandler: @escaping (Result) -> Void) {
        let loginRequestModel = LoginRequestModel(mobileNumber: mobileNumber, password: password)
        apiClient.login(loginRequestModel: loginRequestModel) { response, error in
            if let response = response {
                if response.statusCode < 300 {
                    self.cacheAccessToken(headers: response.response?.allHeaderFields)
                    self.decode(modelType: LoginApiResponseModel.self, from: response) { result in
                        completionHandler(result)
                    }
                } else {
                    self.decodeError(response: response, completionHandler: completionHandler)
                }
            } else if let error = error {
                self.handleMoyaError(error: error, completionHandler: completionHandler)
            }
        }
    }

    private func cacheAccessToken(headers: [AnyHashable: Any]?) {
        guard let token = headers?["access-token"] as? String,
              let client = headers?["client"] as? String,
              let uid = headers?["uid"] as? String
        else { return }
        User.shared.setLoggedIn(token: token, client: client, uid: uid)
    }

    func guestMode(completionHandler: @escaping (Result) -> Void) {
        apiClient.guestMode { response, error in
            if let response = response {
                if response.statusCode < 300 {
                    self.decode(modelType: VersionResponse.self, from: response) { result in
                        completionHandler(result)
                    }
                } else {
                    self.decodeError(response: response, completionHandler: completionHandler)
                }
            } else if let error = error {
                self.handleMoyaError(error: error, completionHandler: completionHandler)
            }
        }
    }

    func loadLoginResponse() -> LoginApiResponseModel? {
        guard let url = Bundle.main.url(forResource: "login_response", withExtension: "json") else {
            return nil
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            decoder.dateDecodingStrategy = .iso8601

            let response = try decoder.decode(LoginApiResponseModel.self, from: data)
            return response
        } catch {
            return nil
        }
    }
}
