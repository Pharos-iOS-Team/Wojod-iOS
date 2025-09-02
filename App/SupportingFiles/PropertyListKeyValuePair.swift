// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

enum AppName: String, Decodable {
    case wojod = "Wojod"
    case hassanElnaggar = "Mr. Hassan Elnaggar"
    case perfectionInPhysics = "Perfection in Physics"
    case royalMedicine = "Royal Medicine"
}

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
