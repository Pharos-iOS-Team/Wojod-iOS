// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation
import Moya

enum ProfileTarget {
    case getProfile(id: String)
    case editProfile(id: String, profile: Profile)
    case fetchDivisions(academicLevel: Int, academicType: Int)
    case fetchBatches(id: String)
}

extension ProfileTarget: TargetType {
    var path: String {
        switch self {
        case .getProfile(let id):
            return "/students/\(id)"
        case .editProfile(let id, _):
            return "/students/\(id)"
        case .fetchDivisions:
            return "/divisions"
        case .fetchBatches(let id):
            return "/divisions/\(id)/batches"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getProfile, .fetchDivisions, .fetchBatches:
            return .get
        case .editProfile:
            return .put
        }
    }

    var task: Task {
        switch self {
        case let .getProfile(id):
            return .requestParameters(parameters: ["id": id], encoding: URLEncoding.default)
        case let .editProfile(_, profile):
            return .requestCustomJSONEncodable(profile, encoder: JSONEncoder.default)
        case let .fetchDivisions(academicLevel, academicType):
            return .requestParameters(parameters: ["education_level": String(academicLevel), "education_type": String(academicType)], encoding: URLEncoding.default)
        default:
            return .requestPlain
        }
    }
}
