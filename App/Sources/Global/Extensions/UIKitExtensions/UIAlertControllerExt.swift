// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit

extension UIAlertController {
    func addActions(_ actions: [UIAlertAction]) {
        actions.forEach { addAction($0) }
    }
}
