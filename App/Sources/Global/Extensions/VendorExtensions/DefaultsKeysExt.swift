// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation
import SwiftyUserDefaults

extension DefaultsKeys {
    var clientKey: DefaultsKey<String?> { .init("client") }
    var fcmToken: DefaultsKey<String?> { .init("fcmToken") }
    var uidKey: DefaultsKey<String?> { .init("uid") }
    var userId: DefaultsKey<Int?> { .init("userId") }
    var isFreshInstall: DefaultsKey<Bool> { .init("isFreshInstall", defaultValue: true) }
}

//extension UserDefaults {
//    var uid: String? {
//        get {
//            return DefaultsKeys[\.uid]
//        }
//        set {
//            DefaultsKeys[\.uid] = uid
//        }
//    }
//}
