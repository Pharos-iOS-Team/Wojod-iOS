// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

struct SpecializationsModel: Codable {
    static let facultyOfMedicine = Specialization(key: 8, value: "Faculty of Medicine")
    var specializations: [Specialization]
}

struct Specialization: Codable {
    var key: Int?
    var value: String?
}
