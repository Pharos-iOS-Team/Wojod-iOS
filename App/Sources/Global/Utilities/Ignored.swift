// Copyright © 2026 Pharos Solutions. All rights reserved.

import Foundation

/// A property wrapper that completely hides a property from Codable synthesis.
@propertyWrapper
struct Ignored<T>: Codable {
    var wrappedValue: T?

    init(wrappedValue: T? = nil) {
        self.wrappedValue = wrappedValue
    }

    init(from decoder: Decoder) throws {
        self.wrappedValue = nil
    }

    func encode(to encoder: Encoder) throws {
        /// Do nothing to prevent it from showing up in outgoing JSON requests
    }
}

/// This intercepts Swift's auto-generated decoding logic. When Swift tries to decode an @Ignored property,
/// this immediately returns nil instead of searching the JSON and crashing when the key is missing.
extension KeyedDecodingContainer {
    func decode<T>(_ type: Ignored<T>.Type, forKey key: Key) throws -> Ignored<T> {
        return Ignored(wrappedValue: nil)
    }
}
