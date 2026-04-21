// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

struct Division: Decodable {
    var key: Int?
    var value: String?

    enum CodingKeys: String, CodingKey {
        case key, value, id, nameEn, nameAr
    }

    init(key: Int?, value: String?) {
        self.key = key
        self.value = value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.key = try container.decodeIfPresent(Int.self, forKey: .key)
        ?? container.decodeIfPresent(Int.self, forKey: .id)

        let nameEn = try container.decodeIfPresent(String.self, forKey: .nameEn)
        let nameAr = try container.decodeIfPresent(String.self, forKey: .nameAr)
        let value = try container.decodeIfPresent(String.self, forKey: .value)

        if let value = value {
            self.value = value
        } else if Language.currentLanguage == .arabic {
            self.value = nameAr
        } else {
            self.value = nameEn
        }
    }
}
