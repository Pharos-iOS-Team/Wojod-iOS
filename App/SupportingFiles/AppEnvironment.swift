// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

enum AppEnvironment {
    static let rootURL: URL = {
        guard let url = URL(string: propertyListKeyValuePair.rootUrl) else { fatalError("Root URL is invalid") }
        return url
    }()

    static let baseURL: URL = {
        guard let url = URL(string: propertyListKeyValuePair.baseUrl) else { fatalError("Base URL is invalid") }
        return url
    }()

    static let baseURLString: String = {
        return propertyListKeyValuePair.baseUrl
    }()

    static let chatBaseURLString: String = {
        return propertyListKeyValuePair.chatBaseUrl
    }()
    
    static let appName: AppName = {
        return AppName.init(rawValue: propertyListKeyValuePair.appName) ?? .wojod
    }()

    static var imageUrl: (String) -> URL = { imagePath in
        guard let url = URL(string: "\(baseURLString)\(imagePath)") else { fatalError("Image URL is invalid") }
        return url
    }

    private static var propertyListKeyValuePair: PropertyListKeyValuePair {
        do {
            return try FileReader.parse(file: "Info", ofType: .plist, to: PropertyListKeyValuePair.self)
        } catch {
            fatalError("Unable to parse Info.plist file")
        }
    }
}
