// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit

@objcMembers
public final class AlertHandler: NSObject {
    private unowned var presentingViewCtrl: UIViewController
    private var passwordTextField: UITextField?
    private var newPasswordTextField: UITextField?
    private var confirmPasswordTextField: UITextField?

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

    func showConfirmAlert(
        title: String,
        message: String,
        confirmButtonTitle: String = L10n.Global.Actions.ok,
        handler: ((UIAlertAction) -> Void)? = nil
    ) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: confirmButtonTitle, style: .default, handler: handler)
        let cancelAction = UIAlertAction(title: L10n.Global.Actions.cancel, style: .cancel)
        alertController.addActions([confirmAction, cancelAction])
        present(alertController)
    }

    func showInformationAlert(title: String, message: String, handler: ((UIAlertAction) -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: L10n.Global.Actions.ok, style: .default, handler: handler)
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

    func showLanguageActionSheet(
        title: String,
        sourceView: UIView,
        selectedLanguage: Language,
        handler: ((UIAlertAction) -> Void)? = nil
    ) {
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet).with {
            $0.modalPresentationStyle = .popover
            $0.popoverPresentationController?.sourceView = sourceView
            $0.popoverPresentationController?.sourceRect = sourceView.bounds
        }
        let englishAction = UIAlertAction(title: L10n.Settings.english, style: .default, handler: handler)
        englishAction.setValue(Colors.sendButtonColor.color, forKey: "titleTextColor")
        englishAction.setValue(selectedLanguage == .english, forKey: "checked")
        let arabicAction = UIAlertAction(title: L10n.Settings.arabic, style: .default, handler: handler)
        arabicAction.setValue(Colors.sendButtonColor.color, forKey: "titleTextColor")
        arabicAction.setValue(selectedLanguage == .arabic, forKey: "checked")
        let cancelAction = UIAlertAction(title: L10n.Global.Actions.cancel, style: .cancel)
        cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
        alertController.addActions([englishAction, arabicAction, cancelAction])
        present(alertController)
    }

    func showQRCodeActionSheet(
        sourceView: UIView,
        onScan: @escaping () -> Void,
        onManual: @escaping () -> Void
    ) {
        let alertController = UIAlertController(
            title: L10n.CourseDetails.Main.bookByQR,
            message: L10n.CourseDetails.Main.selectAnOption,
            preferredStyle: .actionSheet
        ).with {
            $0.popoverPresentationController?.sourceView = sourceView
            $0.popoverPresentationController?.sourceRect = sourceView.bounds
        }
        let scanAction = UIAlertAction(title: L10n.CourseDetails.Main.qrCodeScanner, style: .default) { _ in onScan() }
        let manualAction = UIAlertAction(title: L10n.CourseDetails.Main.codeManually, style: .default) { _ in onManual() }
        let dismissAction = UIAlertAction(title: L10n.Shared.Action.dismiss, style: .cancel)
        alertController.addActions([scanAction, manualAction, dismissAction])
        present(alertController)
    }

    func showNewPasswordAlert(
        title: String,
        sourceView: UIView,
        handler: ((String?, String?, String?) -> Void)? = nil
    ) {
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert).with {
            $0.modalPresentationStyle = .popover
            $0.popoverPresentationController?.sourceView = sourceView
            $0.popoverPresentationController?.sourceRect = sourceView.bounds
        }

        alertController.addTextField(configurationHandler: configurePasswordTextField)
        alertController.addTextField(configurationHandler: configureNewPasswordTextField)
        alertController.addTextField(configurationHandler: configureConfirmationPasswordTextField)
        let confirmAction = UIAlertAction(title: L10n.Global.Actions.confirm, style: .default) {_ in
            if self.newPasswordTextField?.text == self.confirmPasswordTextField?.text
                && self.newPasswordTextField?.text?.isValid ?? false
                && self.confirmPasswordTextField?.text?.isValid ?? false
                && self.passwordTextField?.text?.isValid ?? false {
            handler?(self.passwordTextField?.text, self.newPasswordTextField?.text, self.confirmPasswordTextField?.text)
            } else {
                self.showInformationAlert(title: L10n.Global.Titles.warning, message: "Passwords don't match")
            }
        }
        let cancelAction = UIAlertAction(title: L10n.Global.Actions.cancel, style: .cancel)
        cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
        alertController.addActions([cancelAction, confirmAction])
        present(alertController)
    }

    private func configurePasswordTextField(textField: UITextField) {
        passwordTextField = textField
        passwordTextField?.placeholder = L10n.Login.password
        passwordTextField?.isSecureTextEntry = true
    }

    private func configureNewPasswordTextField(textField: UITextField) {
        newPasswordTextField = textField
        newPasswordTextField?.placeholder = "Enter new password"
        newPasswordTextField?.isSecureTextEntry = true
    }

    private func configureConfirmationPasswordTextField(textField: UITextField) {
        confirmPasswordTextField = textField
        confirmPasswordTextField?.placeholder = "Confirm new Password"
        confirmPasswordTextField?.isSecureTextEntry = true
    }

    private func present(_ alertController: UIAlertController) {
        DispatchQueue.main.async {
            self.presentingViewCtrl.present(alertController, animated: true)
        }
    }
}
