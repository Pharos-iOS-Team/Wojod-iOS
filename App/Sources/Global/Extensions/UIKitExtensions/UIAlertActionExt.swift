// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit

extension UIAlertAction {
    static var cancelAction: UIAlertAction {
        return UIAlertAction(title: L10n.Global.Actions.cancel, style: .cancel)
    }

    static func cancelAction(handler: @escaping () -> Void) -> UIAlertAction {
        return UIAlertAction(title: L10n.Global.Actions.cancel, style: .cancel) { _ in
            handler()
        }
    }
}
