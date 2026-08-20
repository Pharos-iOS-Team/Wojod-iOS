// Copyright © 2021 Pharos Solutions. All rights reserved.

import JGProgressHUD
import PhoneNumberKit
import PhoneNumberKitUI
import UIKit

class ForgotPasswordViewController: UIViewController {
    @IBOutlet private var informationView: UIView! {
        didSet {
            informationView.layer.cornerRadius = 8
            informationView.layer.masksToBounds = true
        }
    }
    @IBOutlet private var informationLabel: UILabel! {
        didSet {
            informationLabel.text = L10n.Login.otpWillBeSent
        }
    }
    @IBOutlet private var alertView: AlertView! {
        didSet {
            alertView.hideAlertView()
        }
    }
    @IBOutlet private var titleLabel: UILabel! {
        didSet {
            titleLabel.text = L10n.Login.forgotPasswordTitle
        }
    }
    @IBOutlet private var mobileNumberTextField: PhoneNumberTextField! {
        didSet {
            // Phone numbers are always LTR even in RTL languages.
            mobileNumberTextField.semanticContentAttribute = .forceLeftToRight
            mobileNumberTextField.textAlignment = .left
            mobileNumberTextField.placeholder = L10n.Login.phoneNumber
            mobileNumberTextField.withFlag = true
            mobileNumberTextField.withDefaultPickerUI = true
            mobileNumberTextField.withPrefix = true
            mobileNumberTextField.addTarget(self, action: #selector(phoneDidChange), for: .editingChanged)
        }
    }
    @IBOutlet private var sendButton: SendButton! {
        didSet {
            sendButton.setTitle(L10n.Login.send)
            sendButton.setImage(Images.localizedDisclosureIndicatorButton)
        }
    }
    @IBOutlet private var backButton: UIButton! {
        didSet {
            backButton.setImage(Images.localizedBackButton)
        }
    }

    private var loadingHud: JGProgressHUD?
    private var viewModel = ForgotPasswordViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        configurePhoneField()
        syncViewModel()
        sendButton.isEnabled = false
        handleErrors()
        handleSuccess()
        showLoadingIndicatorHandler()
    }

    private func configurePhoneField() {
        let code = User.shared.countryCode ?? PhoneNumberValidator.egyptCountryCode
        let digits = code.hasPrefix("+") ? String(code.dropFirst()) : code
        mobileNumberTextField.defaultRegion = UInt64(digits)
            .flatMap { PhoneNumberUtility().mainCountry(forCode: $0) }
            ?? PhoneNumberValidator.egyptRegionCode
        mobileNumberTextField.withExamplePlaceholder = true
        mobileNumberTextField.borderStyle = .none
        mobileNumberTextField.backgroundColor = .white
        mobileNumberTextField.font = .systemFont(ofSize: 14)
        mobileNumberTextField.layer.masksToBounds = true
        mobileNumberTextField.setBorder(color: Asset.Colors.backgroundLightGreyColor.color, width: 1, cornerRadius: 5)
        mobileNumberTextField.flagButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 6)
        mobileNumberTextField.delegate = self
    }

    // MARK: - IBActions

    @IBAction private func sendNumber(_ sender: Any) {
        alertView.hideAlertView()
        send(mobileNumber: mobileNumberTextField.nationalNumber)
    }

    @IBAction private func dismissView(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Private

    @objc private func phoneDidChange() {
        sendButton.isEnabled = !mobileNumberTextField.nationalNumber.isEmpty
        syncViewModel()
    }

    private func syncViewModel() {
        let region = mobileNumberTextField.currentRegion
        let dialCode = dialCodeForRegion(region)
        viewModel.updatePhone(rawNumber: mobileNumberTextField.nationalNumber, countryCode: dialCode, regionCode: region)
    }

    private func dialCodeForRegion(_ region: String) -> String {
        let code = PhoneNumberUtility().countryCode(for: region) ?? 20
        return "+\(code)"
    }

    private func send(mobileNumber: String?) {
        viewModel.sendMobileNumber(mobileNumber: mobileNumber)
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

    private func handleSuccess() {
        viewModel.successHandler = { [weak self] in
            guard let self = self else { return }
            self.hideLoadingIndicator()
            let verifyOtpViewCtrl = StoryboardScene.VerifyOtp.verifyOtpViewController.instantiate().with {
                $0.modalPresentationStyle = .fullScreen
                $0.viewModel = .init(
                    mobileNumber: self.mobileNumberTextField.nationalNumber,
                    countryCode: self.viewModel.selectedCountryCode,
                    otpProvider: .whatsapp,
                    successHandler: {
                        self.hideLoadingIndicator()
                        self.dismiss(animated: true) {
                            self.showCreatePasswordScreen(mobileNumber: self.viewModel.mobileNumber)
                        }
                    }
                )
            }
            self.present(verifyOtpViewCtrl, animated: true)
        }
    }

    private func showCreatePasswordScreen(mobileNumber: String) {
        let createPasswordViewCtrl = StoryboardScene.CreatePassword.createPasswordViewController.instantiate().with {
            $0.viewModel = .init(mobileNumber: mobileNumber, countryCode: self.viewModel.selectedCountryCode)
            $0.modalPresentationStyle = .fullScreen
        }
        present(createPasswordViewCtrl, animated: true)
    }
}

// MARK: - UITextFieldDelegate

extension ForgotPasswordViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let phoneField = textField as? PhoneNumberTextField else { return true }
        return PhoneNumberValidator.shouldAllowEdit(in: phoneField, range: range)
    }
}
