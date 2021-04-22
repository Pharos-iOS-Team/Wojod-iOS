// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

class HomeModel: ModelDecodable {
    private let apiClient = UserProfileApiClient()

    func fetchUserProfile(id: Int, completionHandler: @escaping (Result) -> Void) {
        apiClient.fetchUserProfile(id: User.shared.id ?? 62) { response, error in
            if let response = response {
                if response.statusCode < 300 {
                    self.cacheAccessToken(headers: response.response?.allHeaderFields)
                    self.decode(modelType: StudentModel.self, from: response) { result in
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
