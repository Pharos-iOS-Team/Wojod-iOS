// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation
import Moya

enum AcademicInfoTarget {
    case getEducationalTypes(educationLevel: String, educationType: String)
    case getDivisions(educationLevel: String, educationType: String)
    case getBatches(id: String)
    case getSpecializations(id: String)
}

extension AcademicInfoTarget: TargetType {
    var path: String {
        switch self {
        case .getEducationalTypes:
            return "/education_types"
        case .getDivisions:
            return "/divisions"
        case .getBatches(let id):
            return "/divisions/\(id)/batches"
        case .getSpecializations(let id):
            return "/divisions/\(id)/specializations"
        }
    }

    var method: Moya.Method {
        return .get
    }

    var task: Task {
        switch self {
        case let .getEducationalTypes(educationLevel, educationType):
            return .requestParameters(parameters: ["education_level": educationLevel, "education_type": educationType], encoding: URLEncoding.default)
        case let .getDivisions(educationLevel, educationType):
            return .requestParameters(parameters: ["education_level": educationLevel, "education_type": educationType], encoding: URLEncoding.default)
        case .getBatches:
            return .requestParameters(parameters: [:], encoding: URLEncoding.default)
        case .getSpecializations:
            return .requestParameters(parameters: [:], encoding: URLEncoding.default)
        }
    }
}
