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
            "Accept": "application/json",
            "lang": Language.currentLanguage.rawValue
        ]
    }

    var decoder: JSONDecoder {
        return JSONDecoder.default
    }

    var encoder: JSONEncoder {
        return JSONEncoder.default
    }

    var sharedParameters: [String: Any] {
        return ["locale": Language.currentLanguage.rawValue]
    }

    var sampleData: Data {
        return Data()
    }
}
