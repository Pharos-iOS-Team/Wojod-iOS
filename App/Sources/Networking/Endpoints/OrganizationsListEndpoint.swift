// Copyright © 2026 Pharos Solutions. All rights reserved.

import Foundation
import Moya

enum OrganizationsListEndpoint {
    case getOrganizations
    case registerForOrganization(requestModel: RegisterForOrganizationRequestModel)
}

extension OrganizationsListEndpoint: TargetType {
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
        case let .registerForOrganization(requestModel):
            return .queryParameters(requestModel)
        default:
            return .requestPlain
        }
    }
}
