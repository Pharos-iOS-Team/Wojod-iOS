// Copyright © 2026 Pharos Solutions. All rights reserved.

import Foundation

public struct ApiResponse<T: Decodable>: Decodable {
    public var data: T

    public init(from decoder: Decoder) throws {
        let dynamicKeysContainer = try decoder.container(keyedBy: DynamicKey.self)
        var decoded: T?
        var lastError: Error?
        for key in dynamicKeysContainer.allKeys {
            do {
                decoded = try dynamicKeysContainer.decode(T.self, forKey: key)
                break
            } catch {
                lastError = error
            }
        }
        guard let value = decoded else {
            throw lastError ?? DecodingError.valueNotFound(
                T.self,
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Could not decode \(T.self) from any top-level key."
                )
            )
        }
        data = value
    }
}
