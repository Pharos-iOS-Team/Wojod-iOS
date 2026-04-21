// Copyright © 2026 Pharos Solutions. All rights reserved.
// swiftlint:disable private_outlet

import IQKeyboardManagerSwift
import UIKit

final class PersonalInfoViewController: UIViewController {
    // MARK: - IBOutlets

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var closeButton: UIButton!
    @IBOutlet var signUpTitleImageView: UIImageView! {
        didSet { signUpTitleImageView.image = Images.signUpTitlePageOne }
    }
    @IBOutlet var hintContentView: UIView!
    @IBOutlet var mobileNumberHintLabel: UILabel! {
        didSet { mobileNumberHintLabel.text = L10n.Signup.BasicInfo.whatsappNumberHint }
    }
    @IBOutlet var wrongCredentialsImageView: UIImageView! {
        didSet {
            wrongCredentialsImageView.isHidden = true
            wrongCredentialsImageView.image = Images.wrongCredentials
        }
    }
    @IBOutlet var firstMilestoneImageView: UIImageView!
    @IBOutlet var nextButton: SendButton! {
        didSet { nextButton.isEnabled = false }
    }
    @IBOutlet var loadingIndicator: UIActivityIndicatorView! {
        didSet { loadingIndicator.hidesWhenStopped = true; loadingIndicator.isUserInteractionEnabled = false }
    }
    // MARK: - IBOutlet Collection (all NoCutPasteTextField fields, tagged by PersonalInfoField.rawValue)
    @IBOutlet var inputFields: [NoCutPasteTextField]!

    // MARK: - Properties
    let viewModel: PersonalInfoViewModel
    var pickerCoordinator: PersonalInfoPickerCoordinator?
    let errorDisplay = FormErrorDisplay()
    let countryPickerView = PickerInputView<String>(height: 200)
    let cityPickerView = PickerInputView<String>(height: 200)
    let countryFieldIndicator = UIActivityIndicatorView(style: .medium)
    let cityFieldIndicator = UIActivityIndicatorView(style: .medium)
    let nextButtonIndicator = UIActivityIndicatorView(style: .medium)

    init(viewModel: PersonalInfoViewModel = .init()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.viewModel = PersonalInfoViewModel()
        super.init(coder: coder)
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureSemanticAttribute()
        configureFields()
        let validatedFields = [
            PersonalInfoField.name, .mobileNumber, .mobileNumber2, .email,
            .password, .confirmPassword, .country, .city, .district
        ].compactMap { field(for: $0) }
        errorDisplay.attachErrorLabels(to: validatedFields)
        configureTextFields()
        configurePickerCoordinator()
        retrieveCountriesList()
        restoreStateFromStore()
        scrollView.contentInset.bottom = 120
        firstMilestoneImageView.image = StepIndicatorView.makeImage(currentStep: 1)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideWrongCredentials()
        updateNextButtonState()
    }

    // MARK: - IBActions

    @IBAction private func didTapOnClose(_ sender: UIButton) {
        viewModel.dismissRegistration(from: self)
    }

    @IBAction private func didTapOnNext(_ sender: SendButton) {
        saveStateToStore()
        let errors = viewModel.validationErrors()
        guard errors.isEmpty else {
            showValidationErrors(errors)
            return
        }
        startNextButtonLoading()
        Task { [weak self] in
            guard let self = self else { return }
            let isValid = await self.viewModel.validateNumber()
            await MainActor.run {
                self.stopNextButtonLoading()
                if isValid {
                    self.viewModel.navigateToAcademicInfo(from: self)
                } else {
                    self.displayWrongCredentials()
                    AlertHandler(presentingViewCtrl: self).showConfirmAlert(
                        title: L10n.Global.Titles.error,
                        message: L10n.Signup.BasicInfo.numberAlreadyExistsError
                    )
                }
            }
        }
    }
}

// MARK: - UITextFieldDelegate

extension PersonalInfoViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateNextButtonState()
    }
}

// MARK: - PersonalInfoPickerCoordinatorDelegate

extension PersonalInfoViewController: PersonalInfoPickerCoordinatorDelegate {
    func pickerCoordinatorNeedsButtonUpdate() {
        updateNextButtonState()
    }

    func pickerCoordinatorCountryConfirmed() {
        retrieveCitiesList()
        updateNextButtonState()
    }
}
