// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

struct UserModel: Codable {
    struct DevicesInfo: Codable {}

    struct Preferences: Codable {
        var darkTheme: Bool?
    }
 
    var id: Int?
    var email: String?
    var provider: String?
    var uid: String?
    var batchId: Int?
    var name: String?
    var address: String?
    var mobileNumber: String?
    var mobileNumber2: String?
    var countryCode: String?
    var homeNumber: String?
    var parent1PhoneNumber: String?
    var parent2PhoneNumber: String?
    var country: String?
    var countryName: String?
    var createdAt: String?
    var updatedAt: String?
    var initials: String?
    var city: String?
    var cityName: String?
    var region: String?
    var schoolName: String?
    var specializationId: Int?
    var educationalType: Int?
    var divisionId: Int?
    var otpCode: String?
    var verified: Bool?
    var testUser: Bool?
    var preferences: Preferences
    var avatar: Avatar
    var batchName: String?
    var specializationName: String?
    var divisionName: String?
    var devicesInfo: DevicesInfo?
    var educationTypeName: String?
    var educationLevelName: String?
    var educationLevel: Int?
    var educationType: Int?
    var organizations: [Organization]?
}
