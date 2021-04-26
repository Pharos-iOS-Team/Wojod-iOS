// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit
import DPOTPView
import JGProgressHUD

class VerifyOtpViewController: UIViewController {
    @IBOutlet private var enterOTPLabel: UILabel! {
        didSet {
            enterOTPLabel.textAlignment = Language.textAlignment
            enterOTPLabel.text = L10n.VerifyOtp.pleaseEnterOTP
        }
    }
    @IBOutlet private var sendButton: SendButton! {
        didSet {
            sendButton.setTitle("Continue")
        }
    }
    @IBOutlet private var alertView: AlertView! {
        didSet {
            hideAlertView()
        }
    }
    @IBOutlet private var resendButton: UIButton!
    @IBOutlet private var backButton: UIButton! {
        didSet {
            backButton.setImage(Images.localizedBackButton)
        }
    }
    @IBOutlet private var otpTextView: DPOTPView!
    @IBOutlet private var alertVIewHeightConstraint: NSLayoutConstraint! {
        didSet {
            alertViewHeight = alertVIewHeightConstraint.constant
        }
    }

    var mobileNumber: String = ""
    var alertViewHeight: CGFloat = 0
    let viewModel = VerifyOtpViewModel()
    let loadingHud = JGProgressHUD()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureErrorHandler()
        configureSuccessHandler()
        showLoadingIndicatorHandler()
    }

    @IBAction private func verifyOTP(_ sender: SendButton) {
        confirmOTP()
    }
    @IBAction private func resendOTP(_ sender: UIButton) {
        showAlert()
    }
    @IBAction private func backButton(_ sender: UIButton) {
        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }

    private func confirmOTP() {
        hideAlertView()
        guard let otp = otpTextView.text else { return }
        let otpModel = OtpVerification(mobileNumber: mobileNumber, otpCode: otp)
        viewModel.verifyOtp(otp: otpModel)
    }

    private func configureSuccessHandler() {
        viewModel.successHandler = {
            self.hideLoadingIndicator()
            let createPasswordViewCtrl = StoryboardScene.CreatePassword.createPasswordViewController.instantiate()
            createPasswordViewCtrl.mobileNumber = self.mobileNumber
            createPasswordViewCtrl.modalPresentationStyle = .fullScreen
            self.present(createPasswordViewCtrl, animated: true, completion: nil)
        }
    }

    private func configureErrorHandler() {
        viewModel.errorHandler = { [weak self] error in
            self?.hideLoadingIndicator()
            switch error.type {
            case .validationError:
                self?.showAlertView()
                self?.alertView.message = error.message
            default:
                guard let self = self else { return }
                let alert = AlertHandler(presentingViewCtrl: self)
                alert.showInformationAlert(title: L10n.Global.Titles.error, message: error.message)
            }
        }
    }

    private func showLoadingIndicator() {
        loadingHud.textLabel.text = L10n.Global.Alerts.loading
        loadingHud.show(in: self.view, animated: true)
    }

    private func hideLoadingIndicator() {
        loadingHud.dismiss()
    }

    private func showLoadingIndicatorHandler() {
        viewModel.showIndicator = {
            self.showLoadingIndicator()
        }
    }

    private func hideAlertView() {
        alertVIewHeightConstraint.constant = .zero
        alertView.hideAlertView()
    }

    private func showAlertView() {
        alertVIewHeightConstraint.constant = alertViewHeight
        alertView.showAlertView()
    }

    private func showAlert() {
        let alert = AlertHandler(presentingViewCtrl: self)
        alert.showInformationAlert(title: L10n.VerifyOtp.didNotGetACode, message: L10n.VerifyOtp.didNotGetACodeAlert)
    }
}
