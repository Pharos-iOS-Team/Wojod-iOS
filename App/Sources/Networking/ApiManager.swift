// Copyright © 2021 Pharos Solutions GmbH. All rights reserved.

import Alamofire

class ApiManager {
    let manager = Alamofire.Session(configuration: .default, eventMonitors: [UnauthorizedEventMonitor()])

    var hostUrl: String {
        return "\(AppEnvironment.rootURL)"
    }

    var baseURL: String {
        return "\(AppEnvironment.baseURL)"
    }
}

class UnauthorizedEventMonitor: EventMonitor {
    func requestDidFinish(_ request: Request) {
        if let httpResponse = request.task?.response as? HTTPURLResponse, httpResponse.statusCode == 401 {
            UnauthorizedResponseHandler.shared.handleUnauthorizedResponse()
        }
    }
}
