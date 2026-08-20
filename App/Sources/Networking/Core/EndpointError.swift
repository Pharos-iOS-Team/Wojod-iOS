// Copyright © 2026 Pharos Solutions. All rights reserved.

import Foundation

struct EndpointError: Decodable, Equatable, LocalizedError {
    let errors: [String]

    var errorDescription: String? {
        return errors.first
    }
}
