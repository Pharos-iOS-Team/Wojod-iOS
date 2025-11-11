// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation
import SwiftyUserDefaults

extension DefaultsKeys {
    var clientKey: DefaultsKey<String?> { .init("client") }
    var fcmToken: DefaultsKey<String?> { .init("fcmToken") }
    var uidKey: DefaultsKey<String?> { .init("uid") }
    var userId: DefaultsKey<Int?> { .init("userId") }
    var isFreshInstall: DefaultsKey<Bool> { .init("isFreshInstall", defaultValue: true) }
    var isGuestModeEnabled: DefaultsKey<Bool> { .init("isGuestModeEnabled", defaultValue: false) }
//    var indexOfSelectedCountry: DefaultsKey<Int?> { .init("indexOfSelectedCountry") }
//    var indexOfSelectedCity: DefaultsKey<Int?> { .init("indexOfSelectedCity") }
//    var indexOfSelectedDivision: DefaultsKey<Int?> { .init("indexOfSelectedDivision") }
//    var indexOfSelectedField: DefaultsKey<Int?> { .init("indexOfSelectedField") }
//    var indexOfSelectedYear: DefaultsKey<Int?> { .init("indxOfSelectedYear") }
}
