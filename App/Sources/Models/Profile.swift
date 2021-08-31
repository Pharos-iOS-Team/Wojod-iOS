// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

struct Profile: Codable {
    var email: String?
    var oldPassword: String?
    var password: String?
    var passwordConfirmation: String?
    var country: String?
    var city: String?
    var region: String?
    var address: String?
    var batchId: Int?
    var specializationId: Int?
    var avatarId: Int?
    var homeNumber: String?
    var parent1PhoneNumber: String?
    var parent2PhoneNumber: String?
    var mobileNumber2: String?
    var name: String?
}
