// Copyright © 2026 Pharos Solutions. All rights reserved.

import Foundation

/// Used for parsing JSON with changing key names.
public struct DynamicKey: CodingKey {
    public var stringValue: String
    public var intValue: Int?

    public init?(stringValue: String) {
        self.stringValue = stringValue
    }

    public init?(intValue: Int) {
        self.intValue = intValue
        self.stringValue = String(intValue)
    }
}
