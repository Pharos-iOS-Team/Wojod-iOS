// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit

@objcMembers
public final class AlertHandler: NSObject {
    private unowned var presentingViewCtrl: UIViewController

    init(presentingViewCtrl: UIViewController) {
        self.presentingViewCtrl = presentingViewCtrl
    }

    func showMissingPermissionAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: L10n.Global.Actions.ok, style: .default)
        let settingsAction = UIAlertAction(title: L10n.Global.Titles.settings, style: .default) { _ in
            UIApplication.shared.open(UIApplication.openSettingsURL)
        }
        alertController.addActions([okAction, settingsAction])
        present(alertController)
    }

    func showConfirmAlert(title: String, message: String, confirmButtonTitle: String, handler: ((UIAlertAction) -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: confirmButtonTitle, style: .default, handler: handler)
        let cancelAction = UIAlertAction(title: L10n.Global.Actions.cancel, style: .cancel)
        alertController.addActions([confirmAction, cancelAction])
        present(alertController)
    }

    func showInformationAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: L10n.Global.Actions.ok, style: .default)
        alertController.addAction(confirmAction)
        present(alertController)
    }

    func showConfirmActionSheet(
        title: String,
        message: String,
        confirmButtonTitle: String,
        sourceView: UIView,
        handler: ((UIAlertAction) -> Void)? = nil
    ) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet).with {
            $0.modalPresentationStyle = .popover
            $0.popoverPresentationController?.sourceView = sourceView
        }

        let confirmAction = UIAlertAction(title: confirmButtonTitle, style: .default, handler: handler)
        let cancelAction = UIAlertAction(title: L10n.Global.Actions.cancel, style: .cancel)
        alertController.addActions([confirmAction, cancelAction])
        present(alertController)
    }

    private func present(_ alertController: UIAlertController) {
        DispatchQueue.main.async {
            self.presentingViewCtrl.present(alertController, animated: true)
        }
    }
}
