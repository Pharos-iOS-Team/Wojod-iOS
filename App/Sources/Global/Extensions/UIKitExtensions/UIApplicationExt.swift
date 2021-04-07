// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit

extension UIApplication {
    static var openSettingsURL: URL {
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            preconditionFailure("Invalid Settings URL")
        }
        return url
    }
}
