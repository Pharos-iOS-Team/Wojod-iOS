// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

class OrganizationsListModel: ModelDecodable {
    let apiClient = OrganizationsListApiClient()

    func fetchOrganizations(completion: @escaping (Result) -> Void) {
        apiClient.fetchOrganizationsList { response, error in
            if let response = response {
                if response.statusCode < 300 {
                    self.decode(modelType: Organizations.self, from: response) { result in
                        completion(result)
                    }
                } else {
                    self.decodeError(response: response, completionHandler: completion)
                }
            } else if let error = error {
                completion(.failure(WJError(type: .parsingError, message: error.localizedDescription)))
            }
        }
    }

    func registerForOrganization(organizationId: Int, completion: @escaping (Result) -> Void) {
        apiClient.regsiterForOrganization(organizationId: organizationId) { response, error in
            if let response = response {
                if response.statusCode < 300 {
                    self.decode(modelType: StudentOrganizationModel.self, from: response) { result in
                        completion(result)
                    }
                } else {
                    self.decodeError(response: response, completionHandler: completion)
                }
            } else if let error = error {
                completion(.failure(WJError(type: .parsingError, message: error.localizedDescription)))
            }
        }
    }
}
