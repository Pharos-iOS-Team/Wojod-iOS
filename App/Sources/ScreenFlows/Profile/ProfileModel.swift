// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

class ProfileModel: ModelDecodable {
    let apiClient = ProfileApiClient()

    func editProfile(id: String, profile: Profile, completionHandler: @escaping (Result) -> Void) {
        apiClient.editProfile(id: id, profile: profile) { response, error in
            if let response = response {
                if response.statusCode < 300 {
                    self.decode(modelType: StudentModel.self, from: response) { result in
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
}
