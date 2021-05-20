// Copyright © 2021 Pharos Solutions. All rights reserved.

import SwiftyUserDefaults
import UIKit

class UniversityViewController: UIViewController {
    // MARK: - IBOutlets

    @IBOutlet private var backButton: UIButton! {
        didSet {
            backButton.setImage(Images.localizedBackButton)
        }
    }
    @IBOutlet private var letsKnowMoreTitleImageView: UIImageView! {
        didSet {
            letsKnowMoreTitleImageView.image = Images.letsKnowMoreTitle
        }
    }
    @IBOutlet private var fourthMilestoneImageView: UIImageView! {
        didSet {
            fourthMilestoneImageView.image = Images.fourthMilestone
        }
    }
    @IBOutlet private var studentButton: UIButton! {
        didSet {
            studentButton.setTitle(L10n.Signup.UniversityScreen.student)
            studentButton.layer.cornerRadius = 5
        }
    }
    @IBOutlet private var graduateButton: UIButton! {
        didSet {
            graduateButton.setTitle(L10n.Signup.UniversityScreen.graduate)
            graduateButton.layer.cornerRadius = 5
        }
    }
    @IBOutlet private var universityTextField: NoCutPasteTextField! {
        didSet {
            universityTextField.placeholder = L10n.Signup.UniversityScreen.university
            universityTextField.addRightIcon(Images.path.image, width: 10, height: 6)
            universityTextField.inputView = universityPickerView
            universityTextField.isMandatoryTextField = true
            universityTextField.semanticContentAttribute = Language.semanticContent
            universityTextField.textAlignment = Language.textAlignment
        }
    }
    @IBOutlet private var fieldTextField: NoCutPasteTextField! {
        didSet {
            fieldTextField.placeholder = L10n.Signup.UniversityScreen.field
            fieldTextField.addRightIcon(Images.path.image, width: 10, height: 6)
            fieldTextField.inputView = fieldPickerView
            fieldTextField.isMandatoryTextField = true
            fieldTextField.semanticContentAttribute = Language.semanticContent
            fieldTextField.textAlignment = Language.textAlignment
        }
    }
    @IBOutlet private var yearTextField: NoCutPasteTextField! {
        didSet {
            yearTextField.placeholder = L10n.Signup.UniversityScreen.year
            yearTextField.addRightIcon(Images.path.image, width: 10, height: 6)
            yearTextField.inputView = yearPickerView
            yearTextField.isMandatoryTextField = true
            yearTextField.semanticContentAttribute = Language.semanticContent
            yearTextField.textAlignment = Language.textAlignment
        }
    }
    @IBOutlet private var wrongCredentialsImageView: UIImageView! {
        didSet {
            wrongCredentialsImageView.isHidden = true
            wrongCredentialsImageView.image = Images.wrongCredentials
        }
    }
    @IBOutlet private var wrongCredentialsImageViewHeight: NSLayoutConstraint! {
        didSet {
            wrongCredentialsImageViewHeight.constant = 0
        }
    }
    @IBOutlet private var universityLabel: UILabel! {
        didSet {
            universityLabel.text = L10n.Signup.AcademicInfo.university
        }
    }

    // MARK: - Private Properties

    private var viewModel: RegistrationViewModel?
    private var academicLevel: AcademicLevel = .universityStudent
    private var selectedDivisionIndex: Int = 0
    private var selectedFieldIndex: Int = 0
    private var selectedYearIndex: Int = 0
    private var universities = [String]()
    private var fields = [String]()
    private var years = [String]()
    private var universityPickerView = PickerInputView<String>(height: 200)
    private var fieldPickerView = PickerInputView<String>(height: 200)
    private var yearPickerView = PickerInputView<String>(height: 200)

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = RegistrationViewModel()
        configureSemanticAttribute()
        configureStudentView()
        retrieveUniversities()
        configurePickerViews()
        configurePickerFields()
        displayAlreadyEnteredDataBeforeUserTapsBackIfAny()
    }

    // MARK: - IBActions

    @IBAction private func didTapOnBack(_ sender: UIButton) {
        retrieveInputEnteredFromUser()
        self.dismiss(animated: false)
    }

    @IBAction private func didChooseStudent(_ sender: UIButton) {
        configureStudentView()
        self.academicLevel = .universityStudent
    }

    @IBAction private func didChooseGraduate(_ sender: UIButton) {
        configureGraduateView()
        self.academicLevel = .graduate
    }

    // MARK: - Private Functions

    private func configurePickerFields() {
        universityPickerView.items = { self.universities }
        fieldPickerView.items = { self.fields }
        yearPickerView.items = { self.years }

        universityTextField.keyboardToolbar.doneBarButton.setTarget(
            self,
            action: #selector(universityPickerDoneTapped)
        )
        fieldTextField.keyboardToolbar.doneBarButton.setTarget(
            self,
            action: #selector(fieldPickerDoneTapped)
        )
        yearTextField.keyboardToolbar.doneBarButton.setTarget(
            self,
            action: #selector(yearPickerDoneTapped)
        )
    }

    private func configurePickerViews() {
        universityPickerView.text = { $0 }
        fieldPickerView.text = { $0 }
        yearPickerView.text = { $0 }

        universityPickerView.didSelectAtIndex = { [unowned self] index in
            universityTextField.text = universities[index]
            selectedDivisionIndex = index
            universityTextField.setNormalView()
        }
        fieldPickerView.didSelectAtIndex = { [unowned self] index in
            fieldTextField.text = fields[index]
            selectedFieldIndex = index
            fieldTextField.setNormalView()
        }
        yearPickerView.didSelectAtIndex = { [unowned self] index in
            yearTextField.text = years[index]
            selectedYearIndex = index
            yearTextField.setNormalView()
        }
    }

    private func displayAlreadyEnteredDataBeforeUserTapsBackIfAny() {
        universityTextField.text = User.shared.divisionName
        fieldTextField.text = User.shared.specializationName
        yearTextField.text = User.shared.batchName
    }

    private func configureStudentView() {
        graduateButton.layer.backgroundColor = Colors.backgroundLightGreyColor.color.cgColor
        graduateButton.setTitleColor(.black, for: .normal)
        studentButton.layer.backgroundColor = Colors.backgroundLightPurple.color.cgColor
        studentButton.setTitleColor(Colors.sendButtonColor.color, for: .normal)

        UIView.transition(
            with: yearTextField,
            duration: 0.4,
            options: .transitionCrossDissolve
        ) { [unowned self] in
            yearTextField.isHidden = false
        }
    }

    private func configureGraduateView() {
        studentButton.layer.backgroundColor = Colors.backgroundLightGreyColor.color.cgColor
        studentButton.setTitleColor(.black, for: .normal)
        graduateButton.layer.backgroundColor = Colors.backgroundLightPurple.color.cgColor
        graduateButton.setTitleColor(Colors.sendButtonColor.color, for: .normal)

        UIView.transition(
            with: yearTextField,
            duration: 0.4,
            options: .transitionCrossDissolve
        ) { [unowned self] in
            yearTextField.isHidden = true
        }
    }

    private func retrieveUniversities() {
        viewModel?.loadAcademicDivisions(for: self.academicLevel) { universities in
            self.universities = universities
            self.retrieveFields()
            self.retrieveYears()
        }
    }

    private func retrieveFields() {
        viewModel?.loadSpecializations(for: User.shared.divisionId ?? 0) { fields in
            self.fields = fields
        }
    }

    private func retrieveYears() {
        viewModel?.loadBatches(for: User.shared.divisionId ?? 0) { years in
            self.years = years
        }
    }

    @objc
    private func universityPickerDoneTapped() {
        universityPickerView.resignFirstResponder()
        universityTextField.text = universities[selectedDivisionIndex]
        User.shared.divisionId = viewModel?.divisionIDs[selectedDivisionIndex]
        retrieveFields()
        retrieveYears()
    }

    @objc
    private func fieldPickerDoneTapped() {
        fieldPickerView.resignFirstResponder()
        fieldTextField.text = fields[selectedFieldIndex]
    }

    @objc
    private func yearPickerDoneTapped() {
        yearPickerView.resignFirstResponder()
        yearTextField.text = years[selectedYearIndex]
    }

    private func isMandatoryFieldsFilled() -> Bool {
        switch self.academicLevel {
        case .universityStudent:
            return !universityTextField.isEmpty && !fieldTextField.isEmpty && !yearTextField.isEmpty
        default:
            return !universityTextField.isEmpty && !fieldTextField.isEmpty
        }
    }

    private func configureEmptyMandatoryFields() {
        if universityTextField.isEmpty {
            universityTextField.setErrorView()
        }
        if fieldTextField.isEmpty {
            fieldTextField.setErrorView()
        }
        if yearTextField.isEmpty && academicLevel == .universityStudent {
            yearTextField.setErrorView()
        }
    }

    private func retrieveInputEnteredFromUser() {
        User.shared.academicType = self.academicLevel.rawValue
        User.shared.divisionName = universityTextField.text
        User.shared.specializationName = fieldTextField.text
        User.shared.batch = viewModel?.batchesIDs[selectedYearIndex]
        User.shared.batchName = yearTextField.text
    }

    // MARK: - Segue

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        guard isMandatoryFieldsFilled() == true else {
            wrongCredentialsImageView.isHidden = false
            wrongCredentialsImageViewHeight.constant = 50.0
            configureEmptyMandatoryFields()
            return false
        }
        return true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        retrieveInputEnteredFromUser()
    }
}
