// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit

extension UIViewController {
    var rootViewCtrl: UIViewController? {
        AppDelegate.getAppDelegate()?.window?.rootViewController
    }
}
