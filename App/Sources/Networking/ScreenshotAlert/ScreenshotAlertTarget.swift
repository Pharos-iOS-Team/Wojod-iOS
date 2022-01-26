// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation
import Moya

enum ScreenshotAlertTarget {
    case screenshotAlert(screenName: String, isRecording: Bool, deviceType: Int = .zero)
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
        case let .screenshotAlert(screenName, isRecording, deviceType):
            return .requestParameters(
                parameters: ["screen_name": screenName, "is_recording": isRecording, "device_type": deviceType],
                encoding: URLEncoding.queryString
            )
        }
    }
}
