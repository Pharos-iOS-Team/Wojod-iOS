// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation
import Moya
import SwiftyUserDefaults

extension TargetType {
    var baseURL: URL {
        AppEnvironment.rootURL
    }

    var headers: [String: String]? {
        [
            "Content-Type": "application/json",
            "client": Defaults[\.clientKey] ?? "",
            "uid": Defaults[\.uidKey] ?? "",
            "access-token": KeychainHandler.shared.userToken ?? "",
            "Accept": "application/json",
            "lang": Language.currentLanguage.rawValue
        ]
    }

    var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }

    var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }

    var sharedParameters: [String: Any] {
        return ["locale": Language.currentLanguage.rawValue]
    }

    var sampleData: Data {
        return Data()
    }
}
