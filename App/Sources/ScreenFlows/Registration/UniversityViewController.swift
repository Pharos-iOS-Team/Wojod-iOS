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
        }
    }
    @IBOutlet private var fieldTextField: NoCutPasteTextField! {
        didSet {
            fieldTextField.addRightIcon(Images.path.image, width: 10, height: 6)
            fieldTextField.inputView = fieldPickerView
        }
    }
    @IBOutlet private var yearTextField: NoCutPasteTextField! {
        didSet {
            yearTextField.addRightIcon(Images.path.image, width: 10, height: 6)
            yearTextField.inputView = yearPickerView
        }
    }

    // MARK: - Private Properties

    private var viewModel: RegistrationViewModel?
    private var isStudent = Bool()
    private var selectedDivisionIndex: Int = 0
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

    @IBAction private func didChooseStudent(_ sender: UIButton) {
        configureStudentView()
        self.isStudent = true
    }
    @IBAction private func didChooseGraduate(_ sender: UIButton) {
        configureGraduateView()
        self.isStudent = false
    }

    // MARK: - Private Functions

    private func configurePickerFields() {
        universityPickerView.items = { self.universities }
        fieldPickerView.items = { self.fields }
        yearPickerView.items = { self.years }

        universityTextField.keyboardToolbar.doneBarButton.setTarget(self, action: #selector(pickerDoneTapped))
    }

    private func configurePickerViews() {
        universityPickerView.text = { $0 }
        fieldPickerView.text = { $0 }
        yearPickerView.text = { $0 }

        universityPickerView.didSelectAtIndex = { [unowned self] index in
            universityTextField.text = universities[index]
            self.selectedDivisionIndex = index
        }
        fieldPickerView.didSelectAtIndex = { [unowned self] index in
            fieldTextField.text = fields[index]
        }
        yearPickerView.didSelectAtIndex = { [unowned self] index in
            yearTextField.text = years[index]
            selectedYearIndex = index
        }
    }

    private func configureStudentView() {
        studentButton.layer.backgroundColor = Colors.backgroundLightGreyColor.color.cgColor
        studentButton.setTitleColor(.black, for: .normal)
        graduateButton.layer.backgroundColor = Colors.backgroundLightPurple.color.cgColor
        graduateButton.setTitleColor(Colors.sendButtonColor.color, for: .normal)

        UIView.transition(
            with: yearTextField,
            duration: 0.4,
            options: .transitionCrossDissolve
        ) { [unowned self] in
            yearTextField.isHidden = false
        }
    }

    private func configureGraduateView() {
        graduateButton.layer.backgroundColor = Colors.backgroundLightGreyColor.color.cgColor
        graduateButton.setTitleColor(.black, for: .normal)
        studentButton.layer.backgroundColor = Colors.backgroundLightPurple.color.cgColor
        studentButton.setTitleColor(Colors.sendButtonColor.color, for: .normal)

        UIView.transition(
            with: yearTextField,
            duration: 0.4,
            options: .transitionCrossDissolve
        ) { [unowned self] in
            yearTextField.isHidden = true
        }
    }

    private func retrieveUniversities() {
        let academicLevel: AcademicLevel = isStudent ? .universityStudent : .graduate
        viewModel?.loadAcademicDivisions(for: academicLevel) { universities in
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
    private func pickerDoneTapped() {
        universityPickerView.resignFirstResponder()
        retrieveFields()
        retrieveYears()
    }

    private func isMandatoryFieldsFilled() -> Bool {
        switch isStudent {
        case true:
            return !universityTextField.isEmpty && !fieldTextField.isEmpty && !yearTextField.isEmpty
        default:
            return !universityTextField.isEmpty && !fieldTextField.isEmpty
        }
    }

    // MARK: - Segue

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        guard isMandatoryFieldsFilled() == true else {
            AlertHandler(presentingViewCtrl: self).showInformationAlert(title: "Error", message: "One of the fields is incorrect.")
            return false
        }
        return true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        User.shared.academicType = isStudent ? 1 : 2
        User.shared.university = universityTextField.text
        User.shared.field = fieldTextField.text
        User.shared.batch = viewModel?.batchesIDs[selectedYearIndex]
        User.shared.batchName = yearTextField.text
    }
}
