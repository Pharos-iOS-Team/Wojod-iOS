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
    @IBOutlet private var nextButton: SendButton!
    @IBOutlet private var fieldTextFieldHeightConstraint: NSLayoutConstraint!

    // MARK: - Private Properties

    private var viewModel: RegistrationViewModel?
    private var academicLevel: AcademicLevel = .universityStudent
    private var selectedDivisionIndex: Int = 0
    private var selectedFieldIndex: Int = 0
    private var selectedYearIndex: Int = 0
    private var universities = [Division]()
    private var fields = [Specialization]()
    private var years = [Batch]()
    private var universityPickerView = PickerInputView<String>(height: 200)
    private var fieldPickerView = PickerInputView<String>(height: 200)
    private var yearPickerView = PickerInputView<String>(height: 200)

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = RegistrationViewModel()
        configureSemanticAttribute()
        configureView()
        retrieveUniversities()
        configurePickerViews()
        configurePickerFields()
        displayAlreadyEnteredDataBeforeUserTapsBackIfAny()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideWrongCredentialsError()
    }

    // MARK: - IBActions

    @IBAction private func didTapOnBack(_ sender: UIButton) {
        retrieveInputEnteredFromUser()
        self.dismiss(animated: false)
    }

    @IBAction private func didChooseStudent(_ sender: UIButton) {
        configureStudentView()
        self.academicLevel = .universityStudent
        resetEnteredData()
        retrieveUniversities()
    }

    @IBAction private func didChooseGraduate(_ sender: UIButton) {
        configureGraduateView()
        self.academicLevel = .graduate
        resetEnteredData()
        retrieveUniversities()
    }

    // MARK: - Private Functions

    private func resetEnteredData() {
        universityTextField.text?.removeAll()
        selectedDivisionIndex = 0
    }

    private func configurePickerFields() {
        universityPickerView.items = { self.universities.compactMap { $0.value } }
        fieldPickerView.items = { self.fields.compactMap { $0.value } }
        yearPickerView.items = { self.years.compactMap { $0.value } }

        universityTextField.iq.toolbar.doneBarButton.setTarget(
            self,
            action: #selector(universityPickerDoneTapped)
        )
        fieldTextField.iq.toolbar.doneBarButton.setTarget(
            self,
            action: #selector(fieldPickerDoneTapped)
        )
        yearTextField.iq.toolbar.doneBarButton.setTarget(
            self,
            action: #selector(yearPickerDoneTapped)
        )
    }

    private func configurePickerViews() {
        universityPickerView.text = { $0 }
        fieldPickerView.text = { $0 }
        yearPickerView.text = { $0 }

        universityPickerView.didSelectAtIndex = { [unowned self] index in
            universityTextField.text = universities[index].value
            selectedDivisionIndex = index
            universityTextField.setNormalView()
        }
        fieldPickerView.didSelectAtIndex = { [unowned self] index in
            fieldTextField.text = fields[index].value
            selectedFieldIndex = index
            fieldTextField.setNormalView()
        }
        yearPickerView.didSelectAtIndex = { [unowned self] index in
            guard !years.isEmpty else { return }
            yearTextField.text = years[index].value
            selectedYearIndex = index
            yearTextField.setNormalView()
        }
    }

    private func displayAlreadyEnteredDataBeforeUserTapsBackIfAny() {
        universityTextField.text = User.shared.divisionName
        fieldTextField.text = User.shared.specializationName
        yearTextField.text = User.shared.batchName
    }

    private func configureView() {
        User.shared.academicType == AcademicLevel.graduate.rawValue ? configureGraduateView() : configureStudentView()
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
        viewModel?.loadAcademicDivisions(for: self.academicLevel, in: 0) { universities in
            self.universities = universities ?? []
            self.selectDefaultUniversity()
            self.retrieveFields()
            self.retrieveYears()
        }
    }

    private func retrieveFields() {
        viewModel?.loadSpecializations(for: User.shared.divisionId ?? universities[0].key ?? 0) { [unowned self] fields in
            self.fields = fields ?? []
            if self.fields.isEmpty {
                fieldTextField.isHidden = true
                fieldTextFieldHeightConstraint.constant = 0
            } else {
                self.fields.append(Specialization(key: nil, value: L10n.Signup.School.none))
                fieldTextField.isHidden = false
                fieldTextFieldHeightConstraint.constant = 50
                selectedFieldIndex = 0
                User.shared.specializationId = fields?[0].key
                User.shared.specializationName = fields?[0].value
                fieldTextField.text = self.fields.first { $0.value == L10n.Signup.School.none }?.value
            }
        }
    }

    private func retrieveYears() {
        viewModel?.loadBatches(for: User.shared.divisionId ?? universities[0].key ?? 0) { years in
            self.years = years ?? []
            self.selectedYearIndex = 0
            self.yearTextField.text = years?[0].value
            User.shared.batch = years?[0].key
            User.shared.batchName = years?[0].value
        }
    }

    private func selectDefaultUniversity() {
        User.shared.divisionId = universities[0].key
        User.shared.divisionName = universities[0].value
        universityTextField.text = universities[0].value
    }

    @objc
    private func universityPickerDoneTapped() {
        universityPickerView.resignFirstResponder()
        universityTextField.text = universities[selectedDivisionIndex].value
        User.shared.divisionId = viewModel?.divisionIDs[selectedDivisionIndex]
        retrieveFields()
        retrieveYears()
        // configureNextButtonEnabling()
    }

    @objc
    private func fieldPickerDoneTapped() {
        fieldPickerView.resignFirstResponder()
        fieldTextField.text = fields.isEmpty ? "" : fields[selectedFieldIndex].value
        // configureNextButtonEnabling()
    }

    @objc
    private func yearPickerDoneTapped() {
        guard !years.isEmpty else { return }
        yearPickerView.resignFirstResponder()
        yearTextField.text = years[selectedYearIndex].value
        // configureNextButtonEnabling()
    }

    private func isMandatoryFieldsFilled() -> Bool {
        switch self.academicLevel {
        case .universityStudent:
            if fields.isEmpty {
                return !universityTextField.isEmpty && !yearTextField.isEmpty
            } else {
                return !universityTextField.isEmpty && !fieldTextField.isEmpty && !yearTextField.isEmpty
            }

        default:
            return !universityTextField.isEmpty && !fieldTextField.isEmpty
        }
    }

//    private func configureEmptyMandatoryFields() {
//        if universityTextField.isEmpty {
//            universityTextField.setErrorView()
//        }
//        if fieldTextField.isEmpty {
//            fieldTextField.setErrorView()
//        }
//        if yearTextField.isEmpty && academicLevel == .universityStudent {
//            yearTextField.setErrorView()
//        }
//    }

    private func retrieveInputEnteredFromUser() {
        User.shared.academicType = self.academicLevel.rawValue
        User.shared.divisionName = universityTextField.text
        User.shared.specializationName = fieldTextField.text == L10n.Signup.School.none ? nil : fieldTextField.text
        User.shared.specializationId = viewModel?.specializationsIDs.isEmpty ?? true || fieldTextField.text == L10n.Signup.School.none ? nil : viewModel?.specializationsIDs[selectedFieldIndex]
        User.shared.batch = viewModel?.batchesIDs[selectedYearIndex]
        User.shared.batchName = yearTextField.text
    }

    private func showWrongCredentialsError() {
        wrongCredentialsImageView.isHidden = false
        wrongCredentialsImageViewHeight.constant = 50.0
    }

    private func hideWrongCredentialsError() {
        wrongCredentialsImageView.isHidden = true
        wrongCredentialsImageViewHeight.constant = 0
    }

//    private func configureNextButtonEnabling() {
//        if isMandatoryFieldsFilled() {
//            nextButton.isEnabled = true
//            nextButton.backgroundColor = Colors.sendButtonColor.color
//        } else {
//            nextButton.isEnabled = false
//            nextButton.backgroundColor = Colors.darkGreyColor.color
//        }
//    }

    // MARK: - Segue

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        guard isMandatoryFieldsFilled() == true else {
            showWrongCredentialsError()
            // configureEmptyMandatoryFields()
            return false
        }
        return true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        retrieveInputEnteredFromUser()
    }
}
