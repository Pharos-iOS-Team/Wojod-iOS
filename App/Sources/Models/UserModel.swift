// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

struct LoginApiResponseModel: Decodable {
    var data: UserModel
}

struct StudentModel: Decodable {
    var student: UserModel
}

struct UserModel: Codable {
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
    var preferences: Preferences
    var avatar: Avatar
}

struct Preferences: Codable {
    var locale: String?
    var dartkTheme: Bool?
}

struct Avatar: Codable {
    var id: Int?
    var name: String?
    var fileUrl: String?
    var thumbnailURL: String?
    var createdUrl: String?
    var updatedAt: String?
}
