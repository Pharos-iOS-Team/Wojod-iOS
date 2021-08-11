// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

internal struct Student: Codable {
    private enum CodingKeys: String, CodingKey {
        case name
        case mobileNumber = "mobile_number"
        case secondMobileNumber = "mobile_number2"
        case homeNumber = "home_number"
        case email
        case password
        case confirmPassword = "password_confirmation"
        case country
        case city
        case region
        case address
        case firstParentPhoneNumber = "parent1_phone_number"
        case secondParentPhoneNumber = "parent2_phone_number"
        case schoolName = "school_name"
        case batchID = "batch_id"
        case specializationID = "specialization_id"
        case avatarID = "avatar_id"
    }

    internal let name: String
    internal let mobileNumber: String
    internal let secondMobileNumber: String?
    internal let homeNumber: String?
    internal let email: String
    internal let password: String
    internal let confirmPassword: String
    internal let country: String
    internal let city: String
    internal let region: String
    internal let address: String?
    internal let firstParentPhoneNumber: String
    internal let secondParentPhoneNumber: String?
    internal let schoolName: String
    internal let batchID: Int
    internal let specializationID: Int
    internal let avatarID: Int
}
