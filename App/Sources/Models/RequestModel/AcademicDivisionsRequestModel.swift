// Copyright © 2026 Pharos Solutions. All rights reserved.

import Foundation

struct AcademicRequestModel: Encodable {
    let educationLevel: Int
    let educationType: Int?
    let loginOrganization: String?
    
    public init(educationLevel: Int, educationType: Int? = nil, loginOrganization: String? = nil) {
        self.educationLevel = educationLevel
        self.educationType = educationType
        self.loginOrganization = loginOrganization
    }
}
