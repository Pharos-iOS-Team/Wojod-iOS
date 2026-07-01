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

struct Preferences: Codable {
    var darkTheme: Bool?
}

struct Avatar: Codable {
    var id: Int?
    var name: String?
    var fileUrl: String?
    var thumbnailUrl: String?
}

struct DevicesInfo: Codable {}

struct Organizations: Codable {
    let organizations: [Organization]?
}

// MARK: - Organization
struct Organization: Codable {
    var id: Int?
    var address, name, status: String?
    var media: OrganizationMedia?
}

struct OrganizationMedia: Codable, ContentTypeable {
    var fileName: String?
    var fileUrl: String?
    var thumbnailUrl: String?
    var contentType: String?
}

struct StudentOrganizationModel: Codable {
    let studentOrganization: StudentOrganization?
}

struct StudentOrganization: Codable {
    var id, studentId, organizationId: Int?
    var status, createdAt, updatedAt: String?
}
