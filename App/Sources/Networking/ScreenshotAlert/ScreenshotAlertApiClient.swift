// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation
import Moya

class ScreenshotAlertApiClient {
    let screenshotAlertProvider = MoyaProvider<ScreenshotAlertTarget>()

    func screenshotAlert(screenName: String, completion: @escaping (Response?, MoyaError?) -> Void) {
        screenshotAlertProvider.request(.screenshotAlert(screenName: screenName)) { result in
            switch result {
            case .success(let response):
                completion(response, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
}
