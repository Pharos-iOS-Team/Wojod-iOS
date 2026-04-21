// Copyright © 2026 Pharos Solutions. All rights reserved.


// Copyright © 2023 CommerceBay GmbH. All rights reserved.

import Dependencies
import Foundation

extension DependencyValues {
    enum ApiProviderKey: DependencyKey {
        static let liveValue: ApiProvider = .shared
        static let previewValue: ApiProvider = .shared
        static let testValue: ApiProvider = .shared
    }
}


extension DependencyValues {
    var apiProvider: ApiProvider {
        get { self[ApiProviderKey.self] }
        set { self[ApiProviderKey.self] = newValue }
    }
}
