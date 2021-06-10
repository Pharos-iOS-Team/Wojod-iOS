// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

class VerifyOtpModel: ModelDecodable {
    private let apiClient = ForgotPasswordApiClient()

    func verifyOtp(otp: OtpVerification, completionHandler: @escaping (Result) -> Void) {
        apiClient.verifyOtp(otp: otp) { response, error in
            if let response = response {
                if response.statusCode < 300 {
                    self.cacheAccessToken(headers: response.response?.allHeaderFields)
                    self.decode(modelType: LoginApiResponseModel.self, from: response) { _ in
                        completionHandler(.success(true))
                    }
                } else {
                    self.decodeError(response: response, completionHandler: completionHandler)
                }
            } else if let error = error {
                completionHandler(.failure(WJError(type: .parsingError, message: error.localizedDescription)))
            }
        }
    }

    func verifyOtpFromLogin(otp: OtpVerification, completionHandler: @escaping (Result) -> Void) {
        apiClient.verifyOtpFromLogin(otp: otp) { response, error in
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
                completionHandler(.failure(WJError(type: .parsingError, message: error.localizedDescription)))
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
}
