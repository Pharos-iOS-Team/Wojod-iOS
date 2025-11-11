// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

struct DivisionsModel: Codable {
    static let facultyOfMedicine = Division(key: 8, value: "Faculty of Medicine")
    var divisions: [Division]
}

struct Division: Codable {
    var key: Int?
    var value: String?
}
