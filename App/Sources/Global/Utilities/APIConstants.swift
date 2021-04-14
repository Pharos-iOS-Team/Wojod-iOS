// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

internal enum APIConstants {
    internal static let baseURL: String = "http://courses.pharos-solutions.de"
    internal static let apiPath: String = "/api"
    internal static let studentPortal: String = "/student"
    internal static let versionPath: String = "/v1"
    internal static let rootURL: String = baseURL + apiPath + studentPortal + versionPath
}

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
