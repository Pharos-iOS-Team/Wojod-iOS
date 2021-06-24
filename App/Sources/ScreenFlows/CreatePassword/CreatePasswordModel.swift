// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

class CreatePasswordModel: ModelDecodable {
    private let apiClient = CreatePasswordApiClient()

    func createPassword(password: ForgetPasswordModel, completionHandler: @escaping (Result) -> Void) {
        apiClient.createPassword(password: password) { response, error in
            if let response = response {
                if response.statusCode < 300 {
                    self.decode(modelType: LoginApiResponseModel.self, from: response) { _ in
                        completionHandler(.success(true))
                    }
                } else {
                    self.decodeError(response: response, completionHandler: completionHandler)
                }
            } else if let error = error {
                self.handleMoyaError(error: error, completionHandler: completionHandler)
            }
        }
    }
}
