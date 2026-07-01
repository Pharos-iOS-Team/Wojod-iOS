// Copyright © 2026 Pharos Solutions. All rights reserved.

import Foundation
import Moya

final class LanguagePlugin: PluginType {
    let currentLanguage: () -> Language

    init(currentLanguage: @escaping () -> Language) {
        self.currentLanguage = currentLanguage
    }

    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        guard target is Endpoint else { return request }

        var request = request
        if
            let url = request.url,
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
            let localeItem = URLQueryItem(name: "locale", value: currentLanguage().rawValue)
            var queryItems = components.queryItems ?? []
            queryItems.append(localeItem)
            components.queryItems = queryItems
            request.url = components.url
        }
        return request
    }
}
