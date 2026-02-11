// Copyright © 2026 Pharos Solutions. All rights reserved.

import Foundation
import UIKit

public extension UIWindow {
    static var isPortrait: Bool {
        return keyWindow?
            .interfaceOrientation
            .isPortrait ?? false
    }

    static var keyWindow: UIWindowScene? {
        UIApplication
            .shared
            .connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first
    }
}
