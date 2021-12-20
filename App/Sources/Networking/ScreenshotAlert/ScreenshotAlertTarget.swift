// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation
import Moya

enum ScreenshotAlertTarget {
   case screenshotAlert(screenName: String)
}

extension ScreenshotAlertTarget: TargetType {
    var path: String {
        return "screenshot_alert"
    }

    var method: Moya.Method {
        return .post
    }

    var task: Task {
        switch self {
        case .screenshotAlert(let screenName):
            return .requestJSONEncodable(["screen_name": screenName])
        }
    }
}
