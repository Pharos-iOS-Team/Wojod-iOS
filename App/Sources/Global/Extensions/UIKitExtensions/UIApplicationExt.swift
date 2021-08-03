// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit

extension UIApplication {
    static var openSettingsURL: URL {
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            preconditionFailure("Invalid Settings URL")
        }
        return url
    }

    class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let alert = base as? UIAlertController {
            if let presenting = alert.presentingViewController {
                return topViewController(base: presenting)
            }
        }
        if let presented = base?.presentedViewController, (presented.isKind(of: UIAlertController.self) == false) {
            return topViewController(base: presented)
        }
        return base
    }
}
