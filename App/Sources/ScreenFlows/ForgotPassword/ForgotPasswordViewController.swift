// Copyright © 2021 Pharos Solutions. All rights reserved.

import JGProgressHUD
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
    @IBOutlet private var mobileNumberTextField: UITextField! {
        didSet {
            mobileNumberTextField.semanticContentAttribute = Language.semanticContent
            mobileNumberTextField.textAlignment = Language.textAlignment
            mobileNumberTextField.keyboardType = .asciiCapableNumberPad
            mobileNumberTextField.placeholder = L10n.Login.phoneNumber
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
        handleErrors()
        handleSuccess()
        showLoadingIndicatorHandler()
    }

    @IBAction private func sendNumber(_ sender: Any) {
        alertView.hideAlertView()
        send(mobileNumber: mobileNumberTextField.text)
    }

    @IBAction private func dismissView(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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
        viewModel.successHandler = {  [weak self] in
            guard let self = self else { return }
            self.hideLoadingIndicator()
            let verifyOtpViewCtrl = StoryboardScene.VerifyOtp.verifyOtpViewController.instantiate().with {
                $0.modalPresentationStyle = .fullScreen
                $0.mobileNumber = self.mobileNumberTextField.text ?? ""
                $0.successHandler = {
                    self.hideLoadingIndicator()
                    self.dismiss(animated: true) {
                        self.showCreatePasswordScreen(mobileNumber: self.viewModel.mobileNumber)
                    }
                }
            }
            self.present(verifyOtpViewCtrl, animated: true)
        }
    }

    private func showCreatePasswordScreen(mobileNumber: String) {
        let createPasswordViewCtrl = StoryboardScene.CreatePassword.createPasswordViewController.instantiate().with {
            $0.mobileNumber = mobileNumber
            $0.modalPresentationStyle = .fullScreen
        }
        present(createPasswordViewCtrl, animated: true)
    }
}
