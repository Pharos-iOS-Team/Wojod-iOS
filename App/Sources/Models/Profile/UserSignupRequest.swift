// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

struct UserSignupRequest: Codable {
    let name: String?
    let mobileNumber: String?
    let mobileNumber2: String?
    let homeNumber: String?
    let email: String?
    let password: String?
    let passwordConfirmation: String?
    let country: String?
    let city: String?
    let region: String?
    let address: String?
    let parent1PhoneNumber: String?
    let parent2PhoneNumber: String?
    let schoolName: String?
    let batchId: Int?
    let specializationId: Int?
    let avatarId: Int?
    let isRoyalMedicineStudent: Bool?
    let loginOrganization: String?
}
