// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation
import Moya

enum AcademicInfoTarget {
    case getAcademicType(educationLevel: String, educationType: String)
    case getDivisions(educationLevel: String, educationType: String)
    case getBatches(id: String)
    case getSpecializations(id: String)
}

extension AcademicInfoTarget: TargetType {
    var path: String {
        switch self {
        case .getAcademicType:
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
        case let .getAcademicType(educationLevel, educationType):
            return .requestParameters(
                parameters: [
                    "education_level": educationLevel,
                    "education_type": educationType,
                    "locale": Language.currentLanguage.rawValue
                ],
                encoding: URLEncoding.queryString
            )
        case let .getDivisions(educationLevel, educationType):
            return .requestParameters(
                parameters: [
                    "education_level": educationLevel,
                    "education_type": educationType,
                    "locale": Language.currentLanguage.rawValue
                ],
                encoding: URLEncoding.queryString
            )
        case .getBatches, .getSpecializations:
            return .requestParameters(
                parameters: [
                    "locale": Language.currentLanguage.rawValue
                ],
                encoding: URLEncoding.queryString
            )
        }
    }
}
