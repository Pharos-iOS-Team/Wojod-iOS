// Copyright © 2026 Pharos Solutions. All rights reserved.

import Dependencies
import Foundation
import Moya

extension DependencyValues {
    enum ApiProviderKey: DependencyKey {
        static let liveValue: ApiProvider = .shared
        static let previewValue: ApiProvider = .shared
        static let testValue: ApiProvider = { /// Tests use stubbed data (fake network responses instantly)
            let stubbingProvider = MoyaProvider<Endpoint>(stubClosure: MoyaProvider.immediatelyStub)
            return ApiProvider(provider: stubbingProvider)
        }()
    }
}

extension DependencyValues {
    var apiProvider: ApiProvider {
        get { self[ApiProviderKey.self] }
        set { self[ApiProviderKey.self] = newValue }
    }
}
