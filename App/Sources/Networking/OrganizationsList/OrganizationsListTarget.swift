// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation
import Moya

enum OrganizationsListTarget {
    case getOrganizations
    case registerForOrganization(organizationId: Int)
}

extension OrganizationsListTarget: TargetType {
    var path: String {
        switch self {
        case .getOrganizations:
            return "/organizations"
        case .registerForOrganization:
            return "/student_organizations"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getOrganizations:
            return .get
        case .registerForOrganization:
            return .post
        }
    }

    var task: Task {
        switch self {
        case .getOrganizations:
            return .requestPlain
        case let .registerForOrganization(id):
            return .requestParameters(parameters: ["organization_id": id], encoding: URLEncoding.queryString)
        }
    }
}
