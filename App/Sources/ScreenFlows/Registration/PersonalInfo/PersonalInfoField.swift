// Copyright © 2026 Pharos Solutions. All rights reserved.

import Foundation

enum PersonalInfoField: Int, CaseIterable {
    case name = 100
    case mobileNumber = 101
    case mobileNumber2 = 102
    case email = 103
    case password = 104
    case confirmPassword = 105
    case country = 106
    case city = 107
    case district = 108
    case homeNumber = 109
    case address = 110

    enum ConfigStyle { case mandatory, optional, picker, phone }

    var placeholder: String {
        switch self {
        case .name:
            return L10n.Signup.BasicInfo.name
        case .mobileNumber:
            return L10n.Signup.BasicInfo.mobileNumber
        case .mobileNumber2:
            return L10n.Signup.BasicInfo.mobileNumber2
        case .email:
            return L10n.Signup.BasicInfo.email
        case .password:
            return L10n.Signup.BasicInfo.password
        case .confirmPassword:
            return L10n.Signup.BasicInfo.confirmPassword
        case .country:
            return L10n.Signup.LocationInfo.country
        case .city:
            return L10n.Signup.LocationInfo.city
        case .district:
            return L10n.Signup.LocationInfo.district
        case .homeNumber:
            return L10n.Signup.BasicInfo.homeNumber
        case .address:
            return L10n.Signup.LocationInfo.address
        }
    }

    var configStyle: ConfigStyle {
        switch self {
        case .mobileNumber:
            return .phone
        case .mobileNumber2:
            return .optional
        case .name, .email, .password, .confirmPassword, .district:
            return .mandatory
        case .homeNumber, .address:
            return .optional
        case .country, .city:
            return .picker
        }
    }
}
