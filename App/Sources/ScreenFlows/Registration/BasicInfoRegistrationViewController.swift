// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit

class BasicInfoRegistrationViewController: UIViewController {
    // MARK: - IBOutlets

    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var contentView: UIView!
    @IBOutlet private var nameTextField: UITextField!
    @IBOutlet private var mobileNumberTextField: UITextField!
    @IBOutlet private var homeNumberTextField: UITextField!
    @IBOutlet private var emailTextField: UITextField!
    @IBOutlet private var passwordTextField: UITextField!
    @IBOutlet private var confirmPasswordTextField: UITextField!

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

    // MARK: - Segues

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        guard isMandatoryFieldsFilled(), isPasswordValid(), isMobileNumberValid(), isEmailValid() else {
            AlertHandler(presentingViewCtrl: self).showInformationAlert(title: "Error", message: "One of the fields is incorrect.")
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
