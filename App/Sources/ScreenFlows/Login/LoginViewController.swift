// Copyright © 2021 Pharos Solutions. All rights reserved.

import FirebaseMessaging
import JGProgressHUD
import PhoneNumberKit
import PhoneNumberKitUI
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
    @IBOutlet private var mobileNumberTextField: PhoneNumberTextField! {
        didSet {
            mobileNumberTextField.addTarget(self, action: #selector(phoneDidChange), for: .editingChanged)
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
        configurePhoneField()
        handleErrors()
        showLoadingIndicatorHandler()
        handleGuestMode()
        handleNavigation()
        submitButton.isEnabled = false
    }

    // MARK: - IBActions

    @IBAction private func login(_ sender: SendButton) {
        alertView.hideAlertView()
        viewModel?.submitPhoneNumber(mobileNumber: mobileNumberTextField.nationalNumber)
    }

    @IBAction private func continueAsAGuest(_ sender: UIButton) {
        viewModel?.continueAsAGuest()
    }

    @IBAction private func signUp(_ sender: UIButton) {
        let viewCtrl = StoryboardScene.Registration.initialScene.instantiate()
        viewCtrl.modalPresentationStyle = .fullScreen
        self.present(viewCtrl, animated: true)
    }

    // MARK: - Phone Field Setup

    private func configurePhoneField() {
        mobileNumberTextField.defaultRegion = savedRegion()
        mobileNumberTextField.flagButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 6)
        updateViewModel()
    }

    @objc private func phoneDidChange() {
        updateViewModel()
        submitButton.isEnabled = !mobileNumberTextField.nationalNumber.isEmpty
    }

    /// Returns the region code derived from the stored country code, or Egypt as fallback.
    private func savedRegion() -> String {
        let code = User.shared.countryCode ?? PhoneNumberValidator.egyptCountryCode
        let digits = code.hasPrefix("+") ? String(code.dropFirst()) : code
        return UInt64(digits).flatMap { PhoneNumberUtility().mainCountry(forCode: $0) }
            ?? PhoneNumberValidator.egyptRegionCode
    }

    private func updateViewModel() {
        let region = mobileNumberTextField.currentRegion
        let dialCode = dialCodeForRegion(region)
        viewModel.updatePhone(
            rawNumber: mobileNumberTextField.nationalNumber,
            countryCode: dialCode,
            regionCode: region
        )
    }

    private func dialCodeForRegion(_ region: String) -> String {
        let code = PhoneNumberUtility().countryCode(for: region) ?? 20
        return "+\(code)"
    }

    // MARK: - Navigation

    private func handleNavigation() {
        viewModel?.navigateToPasswordEntry = { [weak self] in
            DispatchQueue.main.async {
                guard let self else { return }
                self.hideLoadingIndicator()
                self.showPasswordScreen(mobileNumber: self.mobileNumberTextField.nationalNumber)
            }
        }
        viewModel?.navigateToOtpVerification = { [weak self] mobileNumber, countryCode in
            DispatchQueue.main.async {
                self?.hideLoadingIndicator()
                self?.showVerifyOtpScreen(mobileNumber: mobileNumber, countryCode: countryCode)
            }
        }
    }

    private func showPasswordScreen(mobileNumber: String) {
        let region = mobileNumberTextField.currentRegion
        let dialCode = dialCodeForRegion(region)
        let passwordViewCtrl = StoryboardScene.PasswordView.passwordViewController.instantiate().with {
            $0.viewModel = .init(mobileNumber: mobileNumber, countryCode: dialCode, regionCode: region)
        }
        navigationController?.pushViewController(passwordViewCtrl, animated: true)
    }

    // MARK: - Loading Indicator

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

    // MARK: - Error Handling

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

    private func handleLoginSuccess() {
        viewModel?.successHandler = { [weak self] _ in
            DispatchQueue.main.async {
                self?.hideLoadingIndicator()
                PushNotificationsManager.shared.sendUserDeviceToken(Messaging.messaging().fcmToken)
                ScreensFlowConfigurationAppDelegate.shared.navigateToMainScreen()
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
                self.showVerifyOtpScreen(
                    mobileNumber: self.mobileNumberTextField.nationalNumber,
                    countryCode: self.viewModel.selectedCountryCode
                )
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
}

// MARK: - UITextFieldDelegate

extension LoginViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let phoneField = textField as? PhoneNumberTextField else { return true }
        return PhoneNumberValidator.shouldAllowEdit(in: phoneField, range: range)
    }
}
