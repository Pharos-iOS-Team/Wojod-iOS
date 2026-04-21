// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

internal struct UserSignupRequest: Codable {
    internal let name: String?
    internal let mobileNumber: String?
    internal let mobileNumber2: String?
    internal let homeNumber: String?
    internal let email: String?
    internal let password: String?
    internal let passwordConfirmation: String?
    internal let country: String?
    internal let city: String?
    internal let region: String?
    internal let address: String?
    internal let parent1PhoneNumber: String?
    internal let parent2PhoneNumber: String?
    internal let schoolName: String?
    internal let batchId: Int?
    internal let specializationId: Int?
    internal let avatarId: Int?
    internal let isRoyalMedicineStudent: Bool?
    internal let loginOrganization: String?
}
