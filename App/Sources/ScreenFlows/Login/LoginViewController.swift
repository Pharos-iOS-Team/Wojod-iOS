// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet private var submitButton: SendButton! {
        didSet {
            submitButton.setTitle(L10n.Login.signIn)
        }
    }
    @IBOutlet private var alertView: AlertView! {
        didSet {
            alertView.isHidden = true
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
    @IBOutlet private var passwordTextField: UITextField! {
        didSet {
            passwordTextField.semanticContentAttribute = Language.semanticContent
            passwordTextField.textAlignment = Language.textAlignment
            passwordTextField.placeholder = L10n.Login.password
        }
    }
    @IBOutlet private var forgotPasswordButton: UIButton! {
        didSet {
            forgotPasswordButton.setTitle(L10n.Login.forgotPassword)
            forgotPasswordButton.contentHorizontalAlignment = Language.currentLanguage == .arabic ? .right : .left
        }
    }
    @IBOutlet private var signUpButton: UIButton! {
        didSet {
            signUpButton.setTitle(L10n.Login.noAccount)
            signUpButton.contentHorizontalAlignment = Language.currentLanguage == .arabic ? .right : .left
        }
    }

    private var viewModel: LoginViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        Language.currentLanguage = .english
        viewModel = LoginViewModel()
        handleLoginSuccess()
        handleErrors()
    }

    @IBAction private func login(_ sender: SendButton) {
        login()
    }

    private func login() {
        guard let number = mobileNumberTextField.text, let password = passwordTextField.text else { return }
        viewModel?.setMobileNumberAndPassword(
            mobileNumber: number,
            password: password
        )
    }

    private func handleErrors() {
        viewModel?.errorHandler = { [weak self] error in
            switch error.type {
            case .validationError:
                self?.alertView.isHidden = false
                self?.alertView.message = error.message
            default:
                guard let self = self else { return }
                let alert = AlertHandler(presentingViewCtrl: self)
                alert.showInformationAlert(title: L10n.Global.Titles.error, message: error.message)
            }
        }
    }

    private func handleLoginSuccess() {
        viewModel?.successHandler = {
            // TODO: Navigate To Main Screen.
        }
    }
}
