// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

struct PropertyListKeyValuePair: Decodable {
    private enum CodingKeys: String, CodingKey {
        case baseUrl = "BASE_URL"
        case rootUrl = "ROOT_URL"
        case chatBaseUrl = "CHAT_BASE_URL"
        case appName = "APP_DISPLAY_NAME"
    }
    
    var baseUrl: String
    var chatBaseUrl: String
    var rootUrl: String
    var appName: String
}
