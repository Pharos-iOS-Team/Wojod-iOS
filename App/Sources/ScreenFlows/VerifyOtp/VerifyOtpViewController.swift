// Copyright © 2021 Pharos Solutions. All rights reserved.

import JGProgressHUD
import UIKit

class VerifyOtpViewController: UIViewController {
    @IBOutlet private var enterOTPLabel: UILabel! {
        didSet {
            enterOTPLabel.textAlignment = Language.textAlignment
            enterOTPLabel.text = L10n.VerifyOtp.pleaseEnterOTP
        }
    }
    @IBOutlet private var sendButton: SendButton! {
        didSet {
            sendButton.setTitle(L10n.VerifyOtp.continue)
        }
    }
    @IBOutlet private var alertView: AlertView! {
        didSet {
            hideAlertView()
        }
    }
    @IBOutlet private var resendButton: UIButton! {
        didSet {
            resendButton.setTitle(L10n.VerifyOtp.resendCode)
        }
    }
    @IBOutlet private var backButton: UIButton! {
        didSet {
            backButton.setImage(Images.localizedBackButton)
        }
    }
    @IBOutlet private var otpTextView: OTPFieldView!
    @IBOutlet private var alertVIewHeightConstraint: NSLayoutConstraint! {
        didSet {
            alertViewHeight = alertVIewHeightConstraint.constant
        }
    }

    var mobileNumber: String = ""
    var otp: String = ""
    var hideBackButton: Bool = false
    var verifyUserFromLogin: Bool = false
    var shouldSendButtonBeUnabled: Bool = false
    var alertViewHeight: CGFloat = 0
    let viewModel = VerifyOtpViewModel()
    let loadingHud = JGProgressHUD()

    var successHandler: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupOtpView()
        configureErrorHandler()
        configureSuccessHandler()
        showLoadingIndicatorHandler()
        configureSendButton()
        configureBackButton()
    }

    @IBAction private func verifyOTP(_ sender: SendButton) {
        confirmOTP()
    }

    @IBAction private func resendOTP(_ sender: UIButton) {
        showAlert()
    }

    @IBAction private func backButton(_ sender: UIButton) {
        AppDelegate.getAppDelegate()?.window?.rootViewController?.dismiss(animated: true)
    }

    func setupOtpView() {
        otpTextView.fieldsCount = 4
        otpTextView.fieldBorderWidth = 2
        otpTextView.defaultBorderColor = Colors.backgroundLightPurple.color
        otpTextView.filledBorderColor = Colors.sendButtonColor.color
        otpTextView.cursorColor = Colors.sendButtonColor.color
        otpTextView.displayType = .underlinedBottom
        otpTextView.fieldSize = 70
        otpTextView.separatorSpace = 10
        otpTextView.shouldAllowIntermediateEditing = false
        otpTextView.delegate = self
        otpTextView.initializeUI()
    }

    private func confirmOTP() {
        hideAlertView()
        let otpModel = OtpVerification(mobileNumber: mobileNumber, otpCode: otp)
        verifyUserFromLogin ? viewModel.verifyOtpFromLogin(otp: otpModel) : viewModel.verifyOtp(otp: otpModel)
    }

    private func configureSendButton() {
        if shouldSendButtonBeUnabled {
            sendButton.setTitleColor(.white, for: .normal)
            sendButton.backgroundColor = Colors.sendButtonColor.color
            sendButton.isEnabled = true
        } else {
            sendButton.setTitleColor(Colors.lightGreyColor.color, for: .disabled)
            sendButton.backgroundColor = Colors.labelGreyColor.color
            sendButton.isEnabled = false
        }
    }
    
    private func configureBackButton() {
        backButton.isHidden = hideBackButton
    }

    private func configureSuccessHandler() {
        viewModel.successHandler = successHandler
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

extension VerifyOtpViewController: OTPFieldViewDelegate {
    func shouldBecomeFirstResponderForOTP(otpTextFieldIndex index: Int) -> Bool {
        true
    }

    func hasEnteredAllOTP(hasEnteredAll: Bool) -> Bool {
        shouldSendButtonBeUnabled = hasEnteredAll
        configureSendButton()
        return hasEnteredAll
    }

    func enteredOTP(otp: String) {
        self.otp = otp
    }
}
