// Copyright © 2020 Pharos Solutions. All rights reserved.

import Foundation

extension Encodable {
    func toDictionary(encoder: JSONEncoder = .default) throws -> [String: Any] {
        let data = try encoder.encode(self)
        return try JSONSerialization.jsonDictionaryObject(with: data, options: .allowFragments)
    }
}
