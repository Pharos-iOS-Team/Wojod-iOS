// Copyright © 2021 Pharos Solutions. All rights reserved.

import JGProgressHUD
import UIKit

class CreatePasswordViewController: UIViewController {
    @IBOutlet private var informationView: UIView! {
        didSet {
            informationView.layer.cornerRadius = 8
            informationView.layer.masksToBounds = true
        }
    }
    @IBOutlet private var informationLabel: UILabel! {
        didSet {
            informationLabel.text = L10n.CreatePassword.passwordLengthTooShort
        }
    }
    @IBOutlet private var alertView: AlertView! {
        didSet {
            alertView.hideAlertView()
        }
    }
    @IBOutlet private var passwordField: UITextField! {
        didSet {
            passwordField.semanticContentAttribute = Language.semanticContent
            passwordField.textAlignment = Language.textAlignment
            passwordField.placeholder = L10n.Login.password
            passwordField.isSecureTextEntry = true
        }
    }
    @IBOutlet private var confirmPasswordField: UITextField! {
        didSet {
            confirmPasswordField.semanticContentAttribute = Language.semanticContent
            confirmPasswordField.textAlignment = Language.textAlignment
            confirmPasswordField.placeholder = L10n.CreatePassword.confirmPassword
            confirmPasswordField.isSecureTextEntry = true
        }
    }
    @IBOutlet private var sendButton: SendButton! {
        didSet {
            sendButton.setTitle(L10n.Login.signIn)
            sendButton.setImage(Images.localizedDisclosureIndicatorButton)
        }
    }
    @IBOutlet private var backButton: UIButton! {
        didSet {
            backButton.setImage(Images.localizedBackButton)
        }
    }
    @IBOutlet private var titleLabel: UILabel! {
        didSet {
            titleLabel.text = L10n.Login.forgotPasswordTitle
        }
    }
    var mobileNumber: String = ""
    private let viewModel = CreatePasswordViewModel()
    private var loadingHud: JGProgressHUD?

    override func viewDidLoad() {
        super.viewDidLoad()
        handleErrors()
        handleSuccess()
        showLoadingIndicatorHandler()
    }

    @IBAction private func createPassword(_ sender: SendButton) {
        alertView.hideAlertView()
        verifyPassword()
    }
    @IBAction private func dismissView(_ sender: Any) {
        self.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }

    private func verifyPassword() {
        viewModel.createPassword(mobileNumber: mobileNumber, password: passwordField.text, passwordConfirmation: confirmPasswordField.text)
    }

    private func showLoadingIndicator() {
        loadingHud = JGProgressHUD()
        loadingHud?.textLabel.text = L10n.Global.Alerts.loading
        loadingHud?.show(in: self.view, animated: true)
    }

    private func hideLoadingIndicator() {
        loadingHud?.dismiss()
    }

    private func showLoadingIndicatorHandler() {
        viewModel.showIndicator = {
            self.showLoadingIndicator()
        }
    }

    private func handleErrors() {
        viewModel.errorHandler = { [weak self] error in
            self?.hideLoadingIndicator()
            switch error.type {
            case .validationError:
                self?.alertView.showAlertView()
                self?.alertView.message = error.message
            default:
                guard let self = self else { return }
                let alert = AlertHandler(presentingViewCtrl: self)
                alert.showInformationAlert(title: L10n.Global.Titles.error, message: error.message)
            }
        }
    }

    private func handleSuccess() {
        viewModel.successHandler = {
            self.hideLoadingIndicator()
            self.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
        }
    }
}
