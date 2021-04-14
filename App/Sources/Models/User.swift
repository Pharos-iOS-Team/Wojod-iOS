// Copyright © 2020 Pharos Solutions GmbH. All rights reserved.

import Foundation

struct LoginApiResponseModel: Decodable {
    var data: User
}

struct User: Codable {
    var id: Int?
    var email: String?
    var provider: String?
    var uid: String?
    var batchId: Int?
    var name: String?
    var address: String?
    var mobileNumber: String?
    var mobileNumber2: String?
    var phoneNumber: String?
    var parent1PhoneNumber: String?
    var parent2PhoneNumber: String?
    var country: String?
    var city: String?
    var region: String?
    var schoolName: String?
    var specializationId: Int?
    var otpCode: Int?
    var verified: Bool?
    var testUser: Bool?
}
