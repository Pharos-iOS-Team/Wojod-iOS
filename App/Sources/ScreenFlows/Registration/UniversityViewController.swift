// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit

class UniversityViewController: UIViewController {
    // MARK: - IBOutlets

    @IBOutlet private var studentButton: UIButton! {
        didSet {
            studentButton.layer.cornerRadius = 5
        }
    }
    @IBOutlet private var graduateButton: UIButton! {
        didSet {
            graduateButton.layer.cornerRadius = 5
        }
    }
    @IBOutlet private var universityTextField: NoCutPasteTextField! {
        didSet {
            universityTextField.addRightIcon(Images.path.image, width: 10, height: 6)
            universityTextField.inputView = universityPickerView
            universityTextField.isMandatoryTextField = true
        }
    }
    @IBOutlet private var fieldTextField: NoCutPasteTextField! {
        didSet {
            fieldTextField.addRightIcon(Images.path.image, width: 10, height: 6)
            fieldTextField.inputView = fieldPickerView
            fieldTextField.isMandatoryTextField = true
        }
    }
    @IBOutlet private var yearTextField: NoCutPasteTextField! {
        didSet {
            yearTextField.addRightIcon(Images.path.image, width: 10, height: 6)
            yearTextField.inputView = yearPickerView
            yearTextField.isMandatoryTextField = true
        }
    }
    @IBOutlet private var wrongCredentialsImageView: UIImageView! {
        didSet {
            wrongCredentialsImageView.isHidden = true
        }
    }
    @IBOutlet private var wrongCredentialsImageViewHeight: NSLayoutConstraint! {
        didSet {
            wrongCredentialsImageViewHeight.constant = 0
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
        configureStudentView()
        retrieveUniversities()
        configurePickerViews()
        configurePickerFields()
    }

    // MARK: - IBActions

    @IBAction private func didTapOnBack(_ sender: UIButton) {
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
            self.selectedDivisionIndex = index
            universityTextField.setNormalView()
        }
        fieldPickerView.didSelectAtIndex = { [unowned self] index in
            fieldTextField.text = fields[index]
            self.selectedFieldIndex = index
            fieldTextField.setNormalView()
        }
        yearPickerView.didSelectAtIndex = { [unowned self] index in
            yearTextField.text = years[index]
            selectedYearIndex = index
            yearTextField.setNormalView()
        }
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
        }
    }

    private func retrieveFields() {
        viewModel?.loadSpecializations(for: self.selectedDivisionIndex) { fields in
            self.fields = fields
        }
    }

    private func retrieveYears() {
        viewModel?.loadBatches(for: self.selectedDivisionIndex) { years in
            self.years = years
        }
    }

    @objc
    private func universityPickerDoneTapped() {
        universityPickerView.resignFirstResponder()
        universityTextField.text = universities[selectedDivisionIndex]
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
        User.shared.academicType = self.academicLevel.rawValue
        User.shared.divisionName = universityTextField.text
        User.shared.specializationName = fieldTextField.text
        User.shared.batch = viewModel?.batchesIDs[selectedYearIndex]
        User.shared.batchName = yearTextField.text
    }
}
