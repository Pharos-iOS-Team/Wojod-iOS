// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

internal struct UserSignupRequest: Codable {
    private enum CodingKeys: String, CodingKey {
        case name
        case mobileNumber = "mobile_number"
        case mobileNumber2 = "mobile_number2"
        case homeNumber = "home_number"
        case email
        case password
        case confirmPassword = "password_confirmation"
        case country
        case city
        case region
        case address
        case firstParentNumber = "parent1_phone_number"
        case secondParentNumber = "parent2_phone_number"
        case schoolName = "school_name"
        case batchID = "batch_id"
        case specializationID = "specialization_id"
        case avatarID = "avatar_id"
        case isRoyalMedicineStudent = "is_royal_medicine_student"
        case loginOrganization = "login_organization"
    }

    internal let name: String?
    internal let mobileNumber: String?
    internal let mobileNumber2: String?
    internal let homeNumber: String?
    internal let email: String?
    internal let password: String?
    internal let confirmPassword: String?
    internal let country: String?
    internal let city: String?
    internal let region: String?
    internal let address: String?
    internal let firstParentNumber: String?
    internal let secondParentNumber: String?
    internal let schoolName: String?
    internal let batchID: Int?
    internal let specializationID: Int?
    internal let avatarID: Int?
    internal let isRoyalMedicineStudent: Bool?
    internal let loginOrganization: String?
}
