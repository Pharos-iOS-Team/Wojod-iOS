// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit

class BasicInfoRegistrationViewController: UIViewController {
    // MARK: - IBOutlets

    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var contentView: UIView!
    @IBOutlet private var mobileLinkedToWhatsappHintLabel: UILabel! {
        didSet {
            mobileLinkedToWhatsappHintLabel.text = L10n.Signup.BasicInfo.whatsappNumberHint
        }
    }
    @IBOutlet private var nameTextField: NoCutPasteTextField! {
        didSet {
            nameTextField.isMandatoryTextField = true
            nameTextField.placeholder = L10n.Signup.BasicInfo.name
            nameTextField.semanticContentAttribute = Language.semanticContent
            nameTextField.textAlignment = Language.textAlignment
        }
    }
    @IBOutlet private var mobileNumberTextField: NoCutPasteTextField! {
        didSet {
            mobileNumberTextField.isMandatoryTextField = true
            mobileNumberTextField.placeholder = L10n.Signup.BasicInfo.mobileNumber
            mobileNumberTextField.semanticContentAttribute = Language.semanticContent
            mobileNumberTextField.textAlignment = Language.textAlignment
        }
    }
    @IBOutlet private var homeNumberTextField: UITextField! {
        didSet {
            homeNumberTextField.placeholder = L10n.Signup.BasicInfo.homeNumber
            homeNumberTextField.semanticContentAttribute = Language.semanticContent
            homeNumberTextField.textAlignment = Language.textAlignment
        }
    }
    @IBOutlet private var emailTextField: NoCutPasteTextField! {
        didSet {
            emailTextField.isMandatoryTextField = true
            emailTextField.placeholder = L10n.Signup.BasicInfo.email
            emailTextField.semanticContentAttribute = Language.semanticContent
            emailTextField.textAlignment = Language.textAlignment
        }
    }
    @IBOutlet private var passwordTextField: NoCutPasteTextField! {
        didSet {
            passwordTextField.isMandatoryTextField = true
            passwordTextField.placeholder = L10n.Signup.BasicInfo.password
            passwordTextField.semanticContentAttribute = Language.semanticContent
            passwordTextField.textAlignment = Language.textAlignment
        }
    }
    @IBOutlet private var confirmPasswordTextField: NoCutPasteTextField! {
        didSet {
            confirmPasswordTextField.isMandatoryTextField = true
            confirmPasswordTextField.placeholder = L10n.Signup.BasicInfo.confirmPassword
            confirmPasswordTextField.semanticContentAttribute = Language.semanticContent
            confirmPasswordTextField.textAlignment = Language.textAlignment
        }
    }
    @IBOutlet private var signUpTitleImageView: UIImageView! {
        didSet {
            signUpTitleImageView.image = Images.signUpTitlePageOne
        }
    }
    @IBOutlet private var wrongCredentialsImageView: UIImageView! {
        didSet {
            wrongCredentialsImageView.isHidden = true
            wrongCredentialsImageView.image = Images.wrongCredentials
        }
    }
    @IBOutlet private var firstMilestoneImageView: UIImageView! {
        didSet {
            firstMilestoneImageView.image = Images.firstMilestone
        }
    }
    @IBOutlet private var hintContentView: UIView!
    @IBOutlet private var mobileNumberHintLabel: UILabel!
    @IBOutlet private var nextButton: SendButton! {
        didSet {
            nextButton.isEnabled = false
        }
    }

    // MARK: - Private Properties

    private var viewModel: RegistrationViewModel?
    private let minimumCharacterCountOfPassword: Int = 6
    private let characterCountOfValidMobileNumber: Int = 11

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureSemanticAttribute()
        configureTextFieldsDelegate()
        viewModel = RegistrationViewModel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureView()
        nextButton.backgroundColor = Colors.darkGreyColor.color
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

    @IBAction private func didTapOnNext(_ sender: SendButton) {
        viewModel?.checkNumberIfValid(mobileNumberTextField.text ?? "", email: emailTextField.text ?? "") { isValid in
            if isValid {
                guard self.isMandatoryFieldsFilled(), self.isPasswordValid(), self.isMobileNumberValid(), self.isEmailValid() else {
                    self.displayWrongCredentialsError()
                    self.configureTextFields()
                    return
                }
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "redirectToLocationInfo", sender: sender)
                }
            } else {
                AlertHandler(presentingViewCtrl: self).showConfirmAlert(
                    title: L10n.Global.Titles.error,
                    message: L10n.Signup.BasicInfo.numberAlreadyExistsError
                )
            }
        }
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        User.shared.name = nameTextField.text
        User.shared.mobileNumber = mobileNumberTextField.text
        User.shared.homeNumber = homeNumberTextField.text
        User.shared.email = emailTextField.text
        User.shared.password = passwordTextField.text ?? ""
    }

    // MARK: - Private Functions

    private func configureView() {
        wrongCredentialsImageView.isHidden = true
        hintContentView.isHidden = false
        mobileNumberHintLabel.isHidden = false
    }

    private func displayWrongCredentialsError() {
        wrongCredentialsImageView.isHidden = false
        hintContentView.isHidden = true
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
        return mobileNumberTextField.text?.count == characterCountOfValidMobileNumber
    }

    private func isEmailValid() -> Bool {
        // swiftlint:disable:next line_length
        let emailRegEx = "^(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?:)+)?(?:(?:(?:[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+(?:\\.[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+)*)|(?:\"(?:(?:(?:(?: )*(?:(?:[!#-Z^-~]|\\[|\\])|(?:\\\\(?:\\t|[ -~]))))+(?: )*)|(?: )+)\"))(?:@)(?:(?:(?:[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)(?:\\.[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)*)|(?:\\[(?:(?:(?:(?:(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))\\.){3}(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))))|(?:(?:(?: )*[!-Z^-~])*(?: )*)|(?:[Vv][0-9A-Fa-f]+\\.[-A-Za-z0-9._~!$&'()*+,;=:]+))\\])))(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?$"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: emailTextField.text)
    }

    private func configureTextFieldsDelegate() {
        nameTextField.delegate = self
        mobileNumberTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
    }
}

// MARK: - Text Field Delegate

extension BasicInfoRegistrationViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        nextButton.isEnabled = isMandatoryFieldsFilled()
        nextButton.layer.backgroundColor = isMandatoryFieldsFilled() ? Colors.sendButtonColor.color.cgColor : Colors.darkGreyColor.color.cgColor
    }
}
