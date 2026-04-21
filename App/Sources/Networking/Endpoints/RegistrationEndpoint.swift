// Copyright © 2026 Pharos Solutions. All rights reserved.

import Foundation
import Moya

enum RegistrationEndpoint {
    case checkNumber(CheckNumberRequestModel)
    case countries
    case cities(CitiesRequestModel)
    case academicTypes(AcademicRequestModel)
    case academicDivisions(AcademicRequestModel)
    case batches(divisionID: Int)
    case specializations(divisionID: Int)
    case signUp(UserSignupRequest)
}

extension RegistrationEndpoint: TargetType {
    var path: String {
        switch self {
        case .checkNumber:
            return "/check_number"
        case .countries:
            return "/countries"
        case .cities:
            return "/cities"
        case .academicTypes:
            return "/education_types"
        case .academicDivisions:
            return "/divisions"
        case let .batches(divisionID):
            return "/divisions/\(divisionID)/batches"
        case let .specializations(divisionID):
            return "/divisions/\(divisionID)/specializations"
        case .signUp:
            return "/students"
        }
    }

    var method: Moya.Method {
        switch self {
        case .signUp:
            return .post
            
        default:
            return .get
        }
    }

    var task: Task {
        switch self {
        case let .checkNumber(requestModel):
            return .queryParameters(requestModel)
        case let .cities(requestModel):
            return .queryParameters(requestModel)
        case let .academicTypes(requestModel):
            return .queryParameters(requestModel)
        case let .academicDivisions(requestModel):
            return .queryParameters(requestModel)
        case let .signUp(userInfo):
            return .requestCustomJSONEncodable(userInfo, encoder: .default)
        default:
            return .requestPlain
        }
    }
}
