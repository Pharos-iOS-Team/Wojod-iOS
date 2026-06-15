// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation
import Moya

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
                completionHandler(.failure(WJError(type: .parsingError, message: error.localizedDescription.replacingOccurrences(of: "URLSessionTask failed with error:", with: ""))))
            }
        }
    }

    func verifyOtpFromLogin(otp: OtpVerification, completionHandler: @escaping (Result) -> Void) {
        apiClient.verifyOtpFromLogin(otp: otp) { response, error in
            if let response = response {
                if response.statusCode < 300 {
                    self.cacheSessionAndUserData(response: response, completionHandler: completionHandler)
                } else {
                    self.decodeError(response: response, completionHandler: completionHandler)
                }
            } else if let error = error {
                self.handleMoyaError(error: error, completionHandler: completionHandler)
            }
        }
    }

    private func cacheSessionAndUserData(response: Moya.Response, completionHandler: @escaping (Result) -> Void) {
        cacheAccessToken(headers: response.response?.allHeaderFields)
        decode(modelType: LoginApiResponseModel.self, from: response) { result in
            switch result {
            case .success(let user as LoginApiResponseModel):
                User.shared.setUserData(user: user.data)
            case .failure(let error):
                print("[AUTH] ⚠️ verify_otp user decode failed: \(error.message)")
            default:
                return
            }
            completionHandler(.success(true))
        }
    }
}
