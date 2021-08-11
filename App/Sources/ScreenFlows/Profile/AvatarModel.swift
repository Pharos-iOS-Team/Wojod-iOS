// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

class AvatarModel: ModelDecodable {
    let apiClient = AvatarApiClient()

    func fetchAvatars(completionHandler: @escaping (Result) -> Void) {
        apiClient.fetchAvatars { response, error in
            if let response = response {
                if response.statusCode < 300 {
                    self.decode(modelType: AvatarsModel.self, from: response) { result in
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
