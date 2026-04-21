// Copyright © 2026 Pharos Solutions. All rights reserved.

import Foundation
import Moya

enum AcademicInfoEndpoint {
    case getAcademicType(AcademicInfoRequestModel)
    case getDivisions(AcademicInfoRequestModel)
    case getBatches(divisionId: String)
    case getSpecializations(divisionId: String)
}

extension AcademicInfoEndpoint: TargetType {
    var path: String {
        switch self {
        case .getAcademicType:
            return "/education_types"
        case .getDivisions:
            return "/divisions"
        case let .getBatches(id):
            return "/divisions/\(id)/batches"
        case let .getSpecializations(id):
            return "/divisions/\(id)/specializations"
        }
    }

    var method: Moya.Method {
        return .get
    }

    var task: Task {
        switch self {
        case let .getAcademicType(requestModel):
            do {
                return .requestParameters(
                    parameters: try requestModel.toDictionary(encoder: .default),
                    encoding: URLEncoding.queryString
                )
            } catch {
                return .requestPlain
            }

        case let .getDivisions(requestModel):
            do {
                return .requestParameters(
                    parameters: try requestModel.toDictionary(encoder: .default),
                    encoding: URLEncoding.queryString
                )
            } catch {
                return .requestPlain
            }

        default:
            return .requestPlain
        }
    }
}
