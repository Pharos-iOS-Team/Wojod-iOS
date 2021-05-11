// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

struct SpecializationsModel: Codable {
    var specializations: [Specialization]
}

struct Specialization: Codable {
    var key: Int?
    var value: String?
}
