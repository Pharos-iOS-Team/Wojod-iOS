// Copyright © 2026 Pharos Solutions. All rights reserved.

import Foundation
import Moya

final class UnauthorizedPlugin: PluginType {
    func didReceive(_ result: Swift.Result<Response, MoyaError>, target: TargetType) {
        switch result {
        case .success(let response):
            if response.statusCode == 401 {
                UnauthorizedResponseHandler.shared.handleUnauthorizedResponse()
            }
        case .failure:
            break
        }
    }
}
