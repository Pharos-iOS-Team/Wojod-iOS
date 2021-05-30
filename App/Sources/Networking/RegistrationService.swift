// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation
import Moya
import SwiftyUserDefaults

internal enum APIPaths {
    internal static let checkNumber: String = "/check_number"
    internal static let countries: String = "/countries"
    internal static let cities: String = "/cities"
    internal static let academicTypes: String = "/education_types"
    internal static let academicDivisions: String = "/divisions"
    internal static let batches: String = "/batches"
    internal static let specializations: String = "/specializations"
    internal static let avatars: String = "/avatars"
    internal static let signUp: String = "/students"
}

internal enum RegistrationService {
    case checkNumber(_ mobileNumber: String, _ email: String)
    case countries
    case cities(_ countryName: String)
    case academicTypes(_ academicLevel: Int)
    case academicDivisions(_ academicLevel: Int)
    case batches(_ divisionID: Int)
    case specializations(_ divisionID: Int)
    case avatars
    case signUp(_ userInfo: UserSignupRequest)
}

extension RegistrationService: TargetType {
    internal var path: String {
        switch self {
        case .checkNumber:
            return APIPaths.checkNumber
        case .countries:
            return APIPaths.countries
        case .cities:
            return APIPaths.cities
        case .academicTypes:
            return APIPaths.academicTypes
        case .academicDivisions:
            return APIPaths.academicDivisions
        case .batches(let divisionID):
            return APIPaths.academicDivisions + "/\(divisionID)" + APIPaths.batches
        case .specializations(let divisionID):
            return APIPaths.academicDivisions + "/\(divisionID)" + APIPaths.specializations
        case .avatars:
            return APIPaths.avatars
        case .signUp:
            return APIPaths.signUp
        }
    }

    internal var method: Moya.Method {
        switch self {
        case .checkNumber, .countries, .cities,
        .academicTypes, .academicDivisions, .batches,
        .specializations, .avatars:
            return .get
        case .signUp:
            return .post
        }
    }

    internal var sampleData: Data {
        return Data()
    }

    internal var task: Task {
        var parameters = [String: Any]()
        switch self {
        case .checkNumber(let mobileNumber, let email):
            return.requestParameters(parameters: ["mobile_number": mobileNumber, "email": email], encoding: URLEncoding.queryString)
        case .countries, .batches, .specializations,
        .avatars:
            return .requestPlain
        case .cities(let countryName):
            return .requestParameters(parameters: ["selected_country": countryName], encoding: URLEncoding.queryString)
        case .academicTypes(let academicLevel):
            return .requestParameters(parameters: ["education_level": academicLevel], encoding: URLEncoding.queryString)
        case .academicDivisions(let academicLevel):
            return .requestParameters(parameters: ["education_level": academicLevel], encoding: URLEncoding.queryString)
        case .signUp(let userInfo):
            guard let params = userInfo.dictionary else { return .requestPlain }
            params.forEach { parameters[$0.key] = $0.value }
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        }
    }
}
