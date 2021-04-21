// Copyright © 2021 Pharos Solutions. All rights reserved.

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
    @IBOutlet private var mobileNumberTextField: UITextField! {
        didSet {
            mobileNumberTextField.semanticContentAttribute = Language.semanticContent
            mobileNumberTextField.textAlignment = Language.textAlignment
            mobileNumberTextField.keyboardType = .asciiCapableNumberPad
            mobileNumberTextField.placeholder = L10n.Login.mobileNumber
        }
    }
    @IBOutlet private var sendButton: SendButton! {
        didSet {
            sendButton.setTitle(L10n.Login.send)
        }
    }

    private var viewModel = ForgotPasswordViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        handleErrors()
    }

    @IBAction private func sendNumber(_ sender: Any) {
        alertView.hideAlertView()
        send(mobileNumber: mobileNumberTextField.text)
    }

    private func send(mobileNumber: String?) {
        viewModel.sendMobileNumber(mobileNumber: mobileNumber)
    }

    private func handleErrors() {
        viewModel.errorHandler = { [weak self] error in
            if error.type == .validationError {
                self?.alertView.showAlertView()
                self?.alertView.message = error.message
            }
        }
    }
}
