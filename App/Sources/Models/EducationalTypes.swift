// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

struct EducationalTypesModel: Codable {
    var educationTypes: [EducationalType]
}

struct EducationalType: Codable {
    var key: Int?
    var value: String?
}
