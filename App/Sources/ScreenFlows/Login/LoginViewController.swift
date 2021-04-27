// Copyright © 2021 Pharos Solutions. All rights reserved.

import JGProgressHUD
import UIKit

class LoginViewController: UIViewController {
    @IBOutlet private var submitButton: SendButton! {
        didSet {
            submitButton.setTitle(L10n.Login.signIn)
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
            forgotPasswordButton.contentHorizontalAlignment = Language.contentHorizontalAlignment
        }
    }
    @IBOutlet private var signUpButton: UIButton! {
        didSet {
            signUpButton.setTitle(L10n.Login.noAccount)
            signUpButton.contentHorizontalAlignment = Language.contentHorizontalAlignment
        }
    }
    @IBOutlet private var scrollView: UIScrollView!

    private var viewModel: LoginViewModel?
    private var loadingHud: JGProgressHUD?

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = LoginViewModel()
        handleLoginSuccess()
        handleErrors()
        showLoadingIndicatorHandler()
    }

    @IBAction private func login(_ sender: SendButton) {
        alertView.hideAlertView()
        login()
    }
    @IBAction private func forgotPassword(_ sender: Any) {
        navigateToForgotPasswordScreen()
    }

    private func login() {
        viewModel?.login(
            mobileNumber: mobileNumberTextField.text,
            password: passwordTextField.text
        )
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
        viewModel?.showIndicator = {
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
                guard let self = self else { return }
                let alert = AlertHandler(presentingViewCtrl: self)
                alert.showInformationAlert(title: L10n.Global.Titles.error, message: error.message)
            }
        }
    }

    private func handleLoginSuccess() {
        viewModel?.successHandler = { [weak self] user in
            self?.hideLoadingIndicator()
            let initialViewCtrl = StoryboardScene.CoursesTabBar.initialScene.instantiate()
            initialViewCtrl.user = user
            AppDelegate.getAppDelegate()?.window?.switchRootViewController(initialViewCtrl)
        }
    }

    private func navigateToForgotPasswordScreen() {
        let forgotPasswordViewCtrl = StoryboardScene.ForgotPassword.forgotPasswordViewController.instantiate()
        forgotPasswordViewCtrl.modalPresentationStyle = .fullScreen
        present(forgotPasswordViewCtrl, animated: true, completion: nil)
    }
}
