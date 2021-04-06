// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit

struct DeviceToken: Encodable {
    var deviceTokenNew: String
    var deviceType: String = "ios"
    var deviceId: String = UIDevice.current.identifierForVendor?.uuidString ?? ""
}
