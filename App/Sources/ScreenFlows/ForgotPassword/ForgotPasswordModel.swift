// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

class ForgotPasswordModel: ModelDecodable {
    private let apiClient = ForgotPasswordApiClient()

    func sendMobileNumber(mobileNumber: String, completionHandler: @escaping (Result) -> Void) {
        apiClient.sendMobileNumber(mobileNumber: mobileNumber) { response, error in
            if let response = response {
                if response.statusCode < 300 {
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
}
