// Copyright © 2021 Pharos Solutions. All rights reserved.

import FirebaseMessaging
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
            sendButton.setTitle(L10n.CreatePassword.setNewPassword)
            sendButton.setImage(Images.localizedDisclosureIndicatorButton)
        }
    }
    @IBOutlet private var titleLabel: UILabel!

    var viewModel = CreatePasswordViewModel()
    private var loadingHud: JGProgressHUD?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        handleErrors()
        handleSuccess()
        configureUI()
        showLoadingIndicatorHandler()
    }

    @objc private func passwordFieldsChanged() {
        let passwordFilled = !(passwordField.text?.isEmpty ?? true)
        let confirmFilled = !(confirmPasswordField.text?.isEmpty ?? true)
        sendButton.isEnabled = passwordFilled && confirmFilled
    }

    @IBAction private func createPassword(_ sender: SendButton) {
        alertView.hideAlertView()
        viewModel.createPassword(
            password: passwordField.text,
            passwordConfirmation: confirmPasswordField.text
        )
    }

    private func configureNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: Images.localizedBackButton,
            style: .plain,
            target: self,
            action: #selector(dismissView)
        )
    }

    @objc private func dismissView() {
        dismiss(animated: true)
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
        viewModel.showIndicator = { [weak self] in
            guard let self = self else { return }
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
        viewModel.successHandler = { [weak self] in
            self?.hideLoadingIndicator()
            if self?.viewModel.isActivationFlow == true {
                PushNotificationsManager.shared.sendUserDeviceToken(Messaging.messaging().fcmToken)
                ScreensFlowConfigurationAppDelegate.shared.navigateToMainScreen()
            } else {
                self?.rootViewCtrl?.dismiss(animated: true)
            }
        }
    }

    private func configureUI() {
        titleLabel.text = viewModel.isActivationFlow ? L10n.Login.welcomePassword : L10n.Login.forgotPasswordTitle
        sendButton.isEnabled = false
        passwordField.addTarget(self, action: #selector(passwordFieldsChanged), for: .editingChanged)
        confirmPasswordField.addTarget(self, action: #selector(passwordFieldsChanged), for: .editingChanged)
    }
}
