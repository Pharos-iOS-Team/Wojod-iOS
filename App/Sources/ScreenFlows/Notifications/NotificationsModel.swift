// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

class NotificationsModel: ModelDecodable {
    let apiClient = NotificationsApiClient()

    func fetchNotifications(completion: @escaping (Result) -> Void) {
        apiClient.fetchNotifications { response, error in
            if let response = response {
                if response.statusCode < 300 {
                    self.decode(modelType: Notifications.self, from: response) { result in
                        completion(result)
                    }
                } else {
                    self.decodeError(response: response, completionHandler: completion)
                }
            } else if let error = error {
                completion(.failure(WJError(type: .parsingError, message: error)))
            }
        }
    }
}
