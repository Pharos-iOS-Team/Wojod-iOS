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

    func fetchOrganizations(completion: @escaping (Organizations) -> Void) {
        model.fetchOrganizations { result in
            switch result {
            case .success(let organizations as Organizations):
                self.organizations = organizations.organizations
                completion(organizations)
            case .failure(let error):
                self.errorHandler?(error)
            default:
                return
            }
        }
    }

    func registerForOrganization(organizationId: Int, completion: @escaping (StudentOrganizationModel) -> Void) {
        model.registerForOrganization(organizationId: organizationId) { result in
            switch result {
            case .success(let organization as StudentOrganizationModel):
                completion(organization)
            case .failure(let error):
                self.errorHandler?(error)
            default:
                return
            }
        }
    }
}
