// Copyright © 2020 Pharos Solutions. All rights reserved.

import Foundation

extension Dictionary {
    func compactMapKeys<T: Hashable>(transform: (Key) -> T?) -> [T: Value] {
        var mappedDictionary = [T: Value]()
        keys.forEach { key in
            if let transformedKey = transform(key) {
                mappedDictionary[transformedKey] = self[key]
            }
        }
        return mappedDictionary
    }
}
