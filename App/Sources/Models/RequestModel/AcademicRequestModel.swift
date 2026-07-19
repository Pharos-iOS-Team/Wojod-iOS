// Copyright © 2026 Pharos Solutions. All rights reserved.

import Foundation

enum AcademicLevel: Int {
    case schoolStudent
    case universityStudent
    case graduate
}

struct AcademicRequestModel: Encodable {
    let educationLevel: Int
    let educationType: Int?
    let loginOrganization: String?

    init(educationLevel: Int, educationType: Int? = nil, loginOrganization: String? = nil) {
        self.educationLevel = educationLevel
        self.educationType = educationType
        self.loginOrganization = loginOrganization
    }
}
