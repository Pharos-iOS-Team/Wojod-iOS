// Copyright © 2021 Pharos Solutions GmbH. All rights reserved.

import Alamofire

class ApiManager {
    let manager = Alamofire.Session.default

    var hostUrl: String {
        return "\(AppEnvironment.rootURL)"
    }

    var baseURL: String {
        return "\(AppEnvironment.baseURL)"
    }
}
