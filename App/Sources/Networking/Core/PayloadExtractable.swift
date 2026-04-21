// Copyright © 2026 Pharos Solutions. All rights reserved.

import Foundation

/// A protocol that is responsible for extracting associated values from enums.
public protocol PayloadExtractable {
    func extractPayload<Payload>() -> Payload?
    func extractPayload<Payload>(ifMatches pattern: (Payload) -> Self) -> Payload?
}

public extension PayloadExtractable {
    typealias DecomposedPayload<Payload> = (label: String, payload: Payload)
    func extractPayload<Payload>() -> Payload? {
        return decompose()?.payload
    }

    func extractPayload<Payload>(ifMatches pattern: (Payload) -> Self) -> Payload? {
        guard
            let decomposed: DecomposedPayload<Payload> = decompose(),
            let patternLabel = Mirror(reflecting: pattern(decomposed.payload)).children.first?.label,
            decomposed.label == patternLabel else { return nil }

        return decomposed.payload
    }

    private func decompose<Payload>() -> DecomposedPayload<Payload>? {
        for case let (label?, value) in Mirror(reflecting: self).children {
            if let result = (value as? Payload) ?? (Mirror(reflecting: value).children.first?.value as? Payload) {
                return (label: label, payload: result)
            }
        }
        return nil
    }
}
