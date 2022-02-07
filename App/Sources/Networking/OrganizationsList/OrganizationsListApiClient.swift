// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation
import Moya

class OrganizationsListApiClient {
    let organizationsListProvider = MoyaProvider<OrganizationsListTarget>()

    func fetchOrganizationsList(completionHandler: @escaping (Response?, MoyaError?) -> Void) {
        organizationsListProvider.request(.getOrganizations) { result in
            switch result {
            case .success(let response):
                completionHandler(response, nil)
            case .failure(let error):
                completionHandler(nil, error)
            }
        }
    }

    func regsiterForOrganization(organizationId: Int, completionHandler: @escaping (Response?, MoyaError?) -> Void) {
        organizationsListProvider.request(.registerForOrganization(organizationId: organizationId)) { result in
            switch result {
            case .success(let response):
                completionHandler(response, nil)
            case .failure(let error):
                completionHandler(nil, error)
            }
        }
    }
}
