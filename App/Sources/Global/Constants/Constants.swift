// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation
enum GlobalConstants {
    enum Application {
        static let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
}
