// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit

class BasicInfoRegistrationViewController: UIViewController {
    // MARK: - IBOutlets

    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var contentView: UIView!
    @IBOutlet private var nameTextField: NoCutPasteTextField! {
        didSet {
            nameTextField.isMandatoryTextField = true
        }
    }
    @IBOutlet private var mobileNumberTextField: NoCutPasteTextField! {
        didSet {
            mobileNumberTextField.isMandatoryTextField = true
        }
    }
    @IBOutlet private var homeNumberTextField: UITextField!
    @IBOutlet private var emailTextField: NoCutPasteTextField! {
        didSet {
            emailTextField.isMandatoryTextField = true
        }
    }
    @IBOutlet private var passwordTextField: NoCutPasteTextField! {
        didSet {
            passwordTextField.isMandatoryTextField = true
        }
    }
    @IBOutlet private var confirmPasswordTextField: NoCutPasteTextField! {
        didSet {
            confirmPasswordTextField.isMandatoryTextField = true
        }
    }
    @IBOutlet private var wrongCredentialsImageView: UIImageView! {
        didSet {
            wrongCredentialsImageView.isHidden = true
        }
    }
    @IBOutlet private var hintContentView: UIView!
    @IBOutlet private var mandatoryCellsHintLabel: UILabel!
    @IBOutlet private var mobileNumberHintLabel: UILabel!

    // MARK: - Private Properties

    private var viewModel: RegistrationViewModel?
    private let minimumCharacterCountOfPassword: Int = 6
    private let characterCountOfValidMobileNumber: Int = 11

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = RegistrationViewModel()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let scrollSize = CGSize(
            width: self.view.frame.size.width,
            height: contentView.frame.size.height
        )
        scrollView.contentSize = scrollSize
    }

    // MARK: - IBActions

    @IBAction private func didTapOnClose(_ sender: UIButton) {
        self.dismiss(animated: true)
    }

    // MARK: - Segues

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        guard isMandatoryFieldsFilled(), isPasswordValid(), isMobileNumberValid(), isEmailValid() else {
            displayWrongCredentialsError()
            configureTextFields()
            return false
        }
        return true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        User.shared.nameEn = nameTextField.text
        User.shared.mobileNumber = mobileNumberTextField.text
        User.shared.homeNumber = homeNumberTextField.text
        User.shared.email = emailTextField.text
        User.shared.password = passwordTextField.text
    }

    // MARK: - Private Functions

    private func displayWrongCredentialsError() {
        wrongCredentialsImageView.isHidden = false
        hintContentView.isHidden = true
        mandatoryCellsHintLabel.isHidden = true
        mobileNumberHintLabel.isHidden = true
    }

    private func configureTextFields() {
        if !isMandatoryFieldsFilled() {
            configureEmptyMandatoryFields()
        }
        if !isPasswordValid() {
            passwordTextField.setErrorView()
            confirmPasswordTextField.setErrorView()
        }
        if !isMobileNumberValid() {
            mobileNumberTextField.setErrorView()
        }
        if !isEmailValid() {
            emailTextField.setErrorView()
        }
    }

    private func configureEmptyMandatoryFields() {
        if nameTextField.isEmpty {
            nameTextField.setErrorView()
        }
        if mobileNumberTextField.isEmpty {
            mobileNumberTextField.setErrorView()
        }
        if emailTextField.isEmpty {
            emailTextField.setErrorView()
        }
        if passwordTextField.isEmpty {
            passwordTextField.setErrorView()
        }
        if confirmPasswordTextField.isEmpty {
            confirmPasswordTextField.setErrorView()
        }
    }

    private func isMandatoryFieldsFilled() -> Bool {
        return !nameTextField.isEmpty && !mobileNumberTextField.isEmpty && !emailTextField.isEmpty &&
        !passwordTextField.isEmpty && !confirmPasswordTextField.isEmpty
    }

    private func isPasswordValid() -> Bool {
        return (passwordTextField.text?.count ?? 0 >= minimumCharacterCountOfPassword) && (passwordTextField.text == confirmPasswordTextField.text)
    }

    private func isMobileNumberValid() -> Bool {
//        var isMobileValid = false
//        viewModel?.checkNumberIfValid(mobileNumberTextField.text ?? "") { isValid in
//            isMobileValid = isValid
//        }
        return mobileNumberTextField.text?.count == characterCountOfValidMobileNumber
    }

    private func isEmailValid() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: emailTextField.text)
    }
}
