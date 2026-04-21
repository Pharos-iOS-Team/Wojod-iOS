// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

class OrganizationsListModel {
    func fetchOrganizations(completion: @escaping (Swift.Result<Organizations, Error>) -> Void) {
        ApiProvider.shared.request(.organizationsList(.getOrganizations), decodeTo: Organizations.self, completion: completion)
    }

    func registerForOrganization(organizationId: Int, completion: @escaping (Swift.Result<StudentOrganizationModel, Error>) -> Void) {
        let requestModel = RegisterForOrganizationRequestModel(organizationId: organizationId)
        ApiProvider.shared.request(.organizationsList(.registerForOrganization(requestModel: requestModel)), decodeTo: StudentOrganizationModel.self, completion: completion)
    }
}
