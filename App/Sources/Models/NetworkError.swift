// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation
import Moya

internal enum `Type`: String, Codable {
    case internalServer
    case authorization
    case `default`
}

internal struct NetworkError: Decodable, Error {
    private enum CodingKeys: String, CodingKey {
        case success
        case errors
    }

    internal var success: Bool?
    internal var errors: [String]?
    internal var type: Type = .default
    internal var message: String? {
        return errors?.first
    }

    internal init(error: Error) {
        errors = [error.localizedDescription]

        switch error._code {
        case 400 ..< 500:
            type = .authorization
        case 500 ..< 600:
            type = .internalServer
        default:
            type = .default
            errors = ["Unexpected behavior"]
        }
    }
}
