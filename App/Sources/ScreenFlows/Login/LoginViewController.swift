// Copyright © 2021 Pharos Solutions. All rights reserved.

import FirebaseMessaging
import JGProgressHUD
import UIKit

class LoginViewController: UIViewController {
    @IBOutlet private var submitButton: SendButton! {
        didSet {
            submitButton.setTitle(L10n.Shared.Titles.continue)
            submitButton.setImage(Images.localizedDisclosureIndicatorButton)
        }
    }
    @IBOutlet private var guestModeButton: UIButton! {
        didSet {
            guestModeButton.setTitle(L10n.Login.guestMode)
            guestModeButton.contentHorizontalAlignment = Language.contentHorizontalAlignment
        }
    }
    @IBOutlet private var alertView: AlertView! {
        didSet {
            alertView.hideAlertView()
        }
    }
    @IBOutlet private var mobileNumberTextField: UITextField! {
        didSet {
            mobileNumberTextField.semanticContentAttribute = Language.semanticContent
            mobileNumberTextField.textAlignment = Language.textAlignment
            mobileNumberTextField.keyboardType = .asciiCapableNumberPad
            mobileNumberTextField.placeholder = L10n.Login.mobileNumber
        }
    }
    @IBOutlet private var signUpButton: UIButton! {
        didSet {
            signUpButton.setTitle(L10n.Login.noAccount)
            signUpButton.contentHorizontalAlignment = Language.contentHorizontalAlignment
        }
    }
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var welcomeLabel: UILabel! {
        didSet {
            welcomeLabel.text = L10n.Login.welcome
        }
    }

    private var viewModel: LoginViewModel!
    private var loadingHud: JGProgressHUD?

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = LoginViewModel()
        handleErrors()
        showLoadingIndicatorHandler()
        handleGuestMode()
        handleNavigation()
        mobileNumberTextField.delegate = self
        submitButton.isEnabled = false
    }

    @IBAction private func login(_ sender: SendButton) {
        alertView.hideAlertView()
        viewModel?.submitPhoneNumber(mobileNumber: mobileNumberTextField.text)
    }

    @IBAction private func continueAsAGuest(_ sender: UIButton) {
        viewModel?.continueAsAGuest()
    }
    @IBAction private func signUp(_ sender: UIButton) {
        let viewCtrl = StoryboardScene.Registration.initialScene.instantiate()
        viewCtrl.modalPresentationStyle = .fullScreen
        self.present(viewCtrl, animated: true)
    }

    private func handleNavigation() {
        viewModel?.navigateToPasswordEntry = { [weak self] in
            DispatchQueue.main.async {
                self?.hideLoadingIndicator()
                self?.showPasswordScreen(mobileNumber: self?.mobileNumberTextField.text ?? "")
            }
        }
        viewModel?.navigateToOtpVerification = { [weak self] mobileNumber in
            DispatchQueue.main.async {
                self?.hideLoadingIndicator()
                self?.showVerifyOtpScreen(mobileNumber: mobileNumber)
            }
        }
    }

    private func showPasswordScreen(mobileNumber: String) {
        let passwordViewCtrl = StoryboardScene.PasswordView.passwordViewController.instantiate().with {
            $0.mobileNumber = mobileNumber
        }
        navigationController?.pushViewController(passwordViewCtrl, animated: true)
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
        viewModel?.showIndicator = { [weak self] in
            guard let self = self else { return }
            self.showLoadingIndicator()
        }
    }

    private func handleErrors() {
        viewModel?.errorHandler = { [weak self] error in
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

    private func handleGuestMode() {
        viewModel?.isGuestModeEnabled { isGuestModeEnabled in
            DispatchQueue.main.async {
                self.guestModeButton.isHidden = !isGuestModeEnabled
            }
        }
    }

    private func showError(_ error: WJError) {
        let alert = AlertHandler(presentingViewCtrl: self)
        alert.showInformationAlert(title: L10n.Global.Titles.error, message: error.message) { _ in
            if self.viewModel.doesErrorIndicateVerificationRequired(error) {
                self.showVerifyOtpScreen(mobileNumber: self.mobileNumberTextField.text ?? "")
            }
        }
    }

    private func showVerifyOtpScreen(mobileNumber: String) {
        let verifyOtpViewCtrl = StoryboardScene.VerifyOtp.verifyOtpViewController.instantiate().with {
            $0.modalPresentationStyle = .fullScreen
            $0.mobileNumber = mobileNumber
            $0.verifyUserFromLogin = true
        }
        verifyOtpViewCtrl.successHandler = { [weak verifyOtpViewCtrl, weak self] in
            guard let presenter = verifyOtpViewCtrl, let self = self else { return }
            if self.viewModel.setPassword {
                let setPasswordViewCtrl = StoryboardScene.CreatePassword.createPasswordViewController.instantiate().with {
                    $0.mobileNumber = mobileNumber
                    $0.isActivationFlow = true
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
        present(verifyOtpViewCtrl, animated: true)
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        submitButton.isEnabled = (mobileNumberTextField.text?.count ?? 0) >= 11
    }
}
