// Copyright © 2026 Pharos Solutions. All rights reserved.

import Foundation
import Moya

extension MoyaProvider {
    static var defaultPlugins: [PluginType] {
        [UnauthorizedPlugin()]
    }

    convenience init(_ additionalPlugins: [PluginType] = []) {
        self.init(plugins: Self.defaultPlugins + additionalPlugins)
    }
}
