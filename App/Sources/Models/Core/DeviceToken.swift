// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit

struct DeviceToken: Encodable {
    var deviceToken: String
    var deviceType: Int = 0
    var deviceId: String = UIDevice.current.identifierForVendor?.uuidString ?? ""
}
