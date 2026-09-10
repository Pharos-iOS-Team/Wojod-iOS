// Copyright © 2021 Pharos Solutions. All rights reserved.

import JGProgressHUD
import PhoneNumberKit
import UIKit

class VerifyOtpViewController: UIViewController {
    @IBOutlet private var enterOTPLabel: UILabel!
    @IBOutlet private var sendButton: SendButton! {
        didSet {
            sendButton.setTitle(L10n.Shared.Titles.continue)
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
            resendButton.setTitleColor(Colors.sendButtonColor.color, for: .normal)
            resendButton.setTitleColor(.gray, for: .disabled)
        }
    }
    @IBOutlet private var otpTextView: OTPFieldView!
    @IBOutlet private var alertVIewHeightConstraint: NSLayoutConstraint! {
        didSet {
            alertViewHeight = alertVIewHeightConstraint.constant
        }
    }
    @IBOutlet private var cooldownLabel: UILabel!
    @IBOutlet private var waitMessageLabel: UILabel! {
        didSet {
            waitMessageLabel.text = L10n.VerifyOtp.waitMessage
        }
    }

    // MARK: - Properties

    var viewModel = VerifyOtpViewModel()
    let loadingHud = JGProgressHUD()
    var alertViewHeight: CGFloat = 0

    private var remainingCooldownSeconds: Int = 0
    private weak var countdownTimer: Timer?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupOtpView()
        configureEnterOTPLabel()
        configureErrorHandler()
        configureResendSuccessHandler()
        showLoadingIndicatorHandler()
        configureSendButton()
        configureNavigationBar()
        startResendCooldown()
    }

    // MARK: - Label Configuration

    private func configureEnterOTPLabel() {
        switch viewModel.otpProvider {
        case .whatsapp:
            enterOTPLabel.text = L10n.VerifyOtp.pleaseEnterOTPViaWhatsApp
        case .sms:
            enterOTPLabel.text = L10n.VerifyOtp.pleaseEnterOTPViaSMS
        }
    }

    deinit {
        countdownTimer?.invalidate()
    }

    // MARK: - IBActions

    @IBAction private func verifyOTP(_ sender: SendButton) {
        confirmOTP()
    }

    @IBAction private func resendOTP(_ sender: UIButton) {
        resendButton.isEnabled = false
        if viewModel.regionCode == PhoneNumberValidator.egyptRegionCode {
            viewModel.otpProvider = .sms
            configureEnterOTPLabel()
        }
        viewModel.resendOTP()
    }

    @objc private func dismissOtp() {
        dismiss(animated: true)
    }

    // MARK: - OTP View Setup

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

    // MARK: - Countdown Timer

    private func startResendCooldown() {
        countdownTimer?.invalidate()
        remainingCooldownSeconds = viewModel.resendCooldownDuration
        resendButton.isEnabled = false
        updateCooldownLabel()
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.tickCountdown()
        }
    }

    private func tickCountdown() {
        remainingCooldownSeconds -= 1
        if remainingCooldownSeconds < 0 {
            stopCooldown()
        } else {
            updateCooldownLabel()
        }
    }

    private func stopCooldown() {
        countdownTimer?.invalidate()
        countdownTimer = nil
        remainingCooldownSeconds = 0
        updateCooldownLabel()
        if viewModel.hasResentOTP {
            resendButton.isHidden = true
            showContactAdminCard()
        } else {
            resendButton.isEnabled = true
        }
    }

    private func showContactAdminCard() {
        alertView.message = L10n.VerifyOtp.contactAdminMessage
        showAlertView()
    }

    private func updateCooldownLabel() {
        let minutes = remainingCooldownSeconds / 60
        let seconds = remainingCooldownSeconds % 60
        cooldownLabel.text = String(format: "%02d:%02d", minutes, seconds)
    }

    // MARK: - Private Helpers

    private func confirmOTP() {
        hideAlertView()
        let formatted = PhoneNumberValidator.formattedEgyptianPhone(viewModel.mobileNumber, countryCode: viewModel.countryCode)
        let otpModel = OtpVerification(mobileNumber: formatted, otpCode: viewModel.otp, countryCode: viewModel.countryCode)
        viewModel.verifyUserFromLogin ? viewModel.verifyOtpFromLogin(otp: otpModel) : viewModel.verifyOtp(otp: otpModel)
    }

    private func configureSendButton() {
        if viewModel.shouldSendButtonBeUnabled {
            sendButton.setTitleColor(.white, for: .normal)
            sendButton.backgroundColor = Colors.sendButtonColor.color
            sendButton.isEnabled = true
        } else {
            sendButton.setTitleColor(Colors.lightGreyColor.color, for: .disabled)
            sendButton.backgroundColor = Colors.labelGreyColor.color
            sendButton.isEnabled = false
        }
    }

    private func configureNavigationBar() {
        guard !viewModel.hideBackButton else { return }
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: Images.localizedBackButton,
            style: .plain,
            target: self,
            action: #selector(dismissOtp)
        )
    }

    private func configureResendSuccessHandler() {
        viewModel.resendSuccessHandler = { [weak self] in
            guard let self else { return }
            self.viewModel.hasResentOTP = true
            self.startResendCooldown()
        }
    }

    private func configureErrorHandler() {
        viewModel.errorHandler = { [weak self] error in
            guard let self else { return }
            self.hideLoadingIndicator()
            self.viewModel.hasResentOTP = false
            self.resendButton.isEnabled = true
            self.countdownTimer?.invalidate()
            self.countdownTimer = nil
            switch error.type {
            case .validationError:
                self.showAlertView()
                self.alertView.message = error.message
            default:
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
        viewModel.showIndicator = { [weak self] in
            guard let self else { return }
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
}

// MARK: - OTPFieldViewDelegate

extension VerifyOtpViewController: OTPFieldViewDelegate {
    func shouldBecomeFirstResponderForOTP(otpTextFieldIndex index: Int) -> Bool {
        true
    }

    func hasEnteredAllOTP(hasEnteredAll: Bool) -> Bool {
        viewModel.shouldSendButtonBeUnabled = hasEnteredAll
        configureSendButton()
        return hasEnteredAll
    }

    func enteredOTP(otp: String) {
        viewModel.otp = otp
    }
}
