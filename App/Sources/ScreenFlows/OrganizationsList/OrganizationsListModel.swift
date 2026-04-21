// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

class OrganizationsListModel {
    func fetchOrganizations(completion: @escaping (Swift.Result<ApiResponse<[Organization]>, Error>) -> Void) {
        ApiProvider.shared.request(.organizationsList(.getOrganizations), decodeTo: ApiResponse<[Organization]>.self, completion: completion)
    }

    func registerForOrganization(organizationId: Int, completion: @escaping (Swift.Result<ApiResponse<StudentOrganization>, Error>) -> Void) {
        let requestModel = RegisterForOrganizationRequestModel(organizationId: organizationId)
        ApiProvider.shared.request(.organizationsList(.registerForOrganization(requestModel: requestModel)), decodeTo: ApiResponse<StudentOrganization>.self, completion: completion)
    }
}
