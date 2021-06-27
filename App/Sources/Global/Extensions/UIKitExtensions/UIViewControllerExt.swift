// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit

extension UIViewController {
    var rootViewCtrl: UIViewController? {
        AppDelegate.getAppDelegate()?.window?.rootViewController
    }

    func getImage(from url: String) -> UIImage? {
        let imageURL = Environment.baseURLString + url
        guard let url = URL(string: imageURL), let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }
}
