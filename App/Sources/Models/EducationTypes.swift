// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

internal struct EducationTypes: Codable {
    private enum CodingKeys: String, CodingKey {
        case educationTypes = "education_types"
    }

    internal let educationTypes: [KeyValue]
}
