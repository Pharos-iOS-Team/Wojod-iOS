// Copyright © 2026 Pharos Solutions. All rights reserved.

import Foundation
import Moya

extension Task {
    static func queryParameters<T: Encodable>(
        _ model: T,
        encoding: ParameterEncoding = URLEncoding.queryString
    ) -> Task {
        guard let params = try? model.toDictionary() else {
            assertionFailure("Failed to encode \(T.self) into request parameters")
            return .requestParameters(parameters: [:], encoding: encoding)
        }
        return .requestParameters(parameters: params, encoding: encoding)
    }
}
