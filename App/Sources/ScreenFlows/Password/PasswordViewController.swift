// Copyright © 2021 Pharos Solutions. All rights reserved.

import FirebaseMessaging
import JGProgressHUD
import PhoneNumberKit
import UIKit

class PasswordViewController: UIViewController {
    @IBOutlet private var phoneNumberLabel: UILabel!
    @IBOutlet private var welcomeLabel: UILabel! {
        didSet {
            welcomeLabel.text = L10n.Login.welcomePassword
        }
    }
    @IBOutlet private var passwordTextField: UITextField! {
        didSet {
            passwordTextField.semanticContentAttribute = Language.semanticContent
            passwordTextField.textAlignment = Language.textAlignment
            passwordTextField.placeholder = L10n.Login.password
        }
    }
    @IBOutlet private var loginButton: SendButton! {
        didSet {
            loginButton.setTitle(L10n.Login.signIn)
            loginButton.setImage(Images.localizedDisclosureIndicatorButton)
        }
    }
    @IBOutlet private var forgotPasswordButton: UIButton! {
        didSet {
            forgotPasswordButton.setTitle(L10n.Login.forgotPassword)
            forgotPasswordButton.contentHorizontalAlignment = Language.contentHorizontalAlignment
        }
    }
    @IBOutlet private var alertView: AlertView! {
        didSet {
            alertView.hideAlertView()
        }
    }
    @IBOutlet private var scrollView: UIScrollView!

    var viewModel = LoginViewModel()
    private var loadingHud: JGProgressHUD?

    override func viewDidLoad() {
        super.viewDidLoad()
        configurePhoneNumberLabel()
        configureBackButton()
        handleLoginSuccess()
        handleErrors()
        showLoadingIndicatorHandler()
        handleNavigation()
        passwordTextField.delegate = self
        loginButton.isEnabled = false
    }

    // MARK: - Phone Number Display

    private func configurePhoneNumberLabel() {
        let displayNumber = PhoneNumberValidator.stripEgyptianLeadingZero(viewModel.mobileNumber, countryCode: viewModel.selectedCountryCode)
        let flag = PhoneNumberValidator.flagEmoji(forRegionCode: viewModel.selectedRegionCode)
        phoneNumberLabel.text = "\(flag) \(viewModel.selectedCountryCode) \(displayNumber)"
        phoneNumberLabel.textColor = .gray
        phoneNumberLabel.textAlignment = .left
        phoneNumberLabel.semanticContentAttribute = .forceLeftToRight
    }

    // MARK: - Navigation Bar

    private func configureBackButton() {
        let backItem = UIBarButtonItem(
            image: Images.localizedBackButton,
            style: .plain,
            target: self,
            action: #selector(handleBack)
        )
        backItem.tintColor = .black
        navigationItem.leftBarButtonItem = backItem
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
            navigationController?.setNavigationBarHidden(true, animated: true)
        }
    }

    @objc
    private func handleBack() {
        navigationController?.popViewController(animated: true)
    }

    @IBAction private func login(_ sender: SendButton) {
        alertView.hideAlertView()
        viewModel.login(mobileNumber: viewModel.mobileNumber, password: passwordTextField.text)
    }

    @IBAction private func forgotPassword(_ sender: Any) {
        navigateToForgotPasswordScreen()
    }

    private func handleNavigation() {
        viewModel.navigateToOtpVerification = { [weak self] mobileNumber, countryCode in
            DispatchQueue.main.async {
                self?.hideLoadingIndicator()
                self?.showVerifyOtpScreen(mobileNumber: mobileNumber, countryCode: countryCode)
            }
        }
    }

    private func showVerifyOtpScreen(mobileNumber: String, countryCode: String) {
        let verifyOtpViewCtrl = StoryboardScene.VerifyOtp.verifyOtpViewController.instantiate()
        verifyOtpViewCtrl.modalPresentationStyle = .fullScreen
        verifyOtpViewCtrl.viewModel = .init(
            mobileNumber: mobileNumber,
            countryCode: countryCode,
            otpProvider: .whatsapp,
            verifyUserFromLogin: true,
            successHandler: { [weak verifyOtpViewCtrl, weak self] in
                guard let presenter = verifyOtpViewCtrl, let self = self else { return }
                if self.viewModel.setPassword {
                    let setPasswordViewCtrl = StoryboardScene.CreatePassword.createPasswordViewController.instantiate().with {
                        $0.viewModel = .init(mobileNumber: mobileNumber, countryCode: countryCode, isActivationFlow: true)
                        $0.modalPresentationStyle = .fullScreen
                    }
                    presenter.present(setPasswordViewCtrl, animated: true)
                } else {
                    DispatchQueue.main.async {
                        PushNotificationsManager.shared.sendUserDeviceToken(Messaging.messaging().fcmToken)
                        ScreensFlowConfigurationAppDelegate.shared.navigateToMainScreen()
                    }
                }
            }
        )
        present(verifyOtpViewCtrl, animated: true)
    }

    private func handleLoginSuccess() {
        viewModel.successHandler = { [weak self] _ in
            self?.hideLoadingIndicator()
            PushNotificationsManager.shared.sendUserDeviceToken(Messaging.messaging().fcmToken)
            ScreensFlowConfigurationAppDelegate.shared.navigateToMainScreen()
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
                self?.showError(error)
            }
        }
    }

    private func showError(_ error: WJError) {
        let alert = AlertHandler(presentingViewCtrl: self)
        alert.showInformationAlert(title: L10n.Global.Titles.error, message: error.message) { _ in
            if self.viewModel.doesErrorIndicateVerificationRequired(error) {
                self.showVerifyOtpScreen(mobileNumber: self.viewModel.mobileNumber, countryCode: self.viewModel.selectedCountryCode)
            }
        }
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

    private func navigateToForgotPasswordScreen() {
        let forgotPasswordViewCtrl = StoryboardScene.ForgotPassword.forgotPasswordViewController.instantiate()
        forgotPasswordViewCtrl.modalPresentationStyle = .fullScreen
        present(forgotPasswordViewCtrl, animated: true, completion: nil)
    }
}

extension PasswordViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidChangeSelection(_ textField: UITextField) {
        loginButton.isEnabled = !(passwordTextField.text?.isEmpty ?? true)
    }
}
