// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

enum OrganizationStatus: String {
    case notRegistered
    case pending
    case approved
    case declined
}

class OrganizationsListViewModel {
    let model = OrganizationsListModel()
    var organizations: [Organization]?

    var errorHandler: ((WJError) -> Void)?

    func fetchOrganizations(completion: @escaping ([Organization]) -> Void) {
        model.fetchOrganizations { result in
            switch result {
            case .success(let organizations):
                self.organizations = organizations.data
                completion(organizations.data)
            case .failure(let error):
                self.errorHandler?(WJError(type: .parsingError, message: error.localizedDescription))
            }
        }
    }

    func registerForOrganization(organizationId: Int, completion: @escaping (StudentOrganization) -> Void) {
        model.registerForOrganization(organizationId: organizationId) { result in
            switch result {
            case .success(let organization):
                completion(organization.data)
            case .failure(let error):
                self.errorHandler?(WJError(type: .parsingError, message: error.localizedDescription))
            }
        }
    }
}
