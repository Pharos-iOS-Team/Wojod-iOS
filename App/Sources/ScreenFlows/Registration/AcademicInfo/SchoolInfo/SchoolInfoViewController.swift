// Copyright © 2026 Pharos Solutions. All rights reserved.

import IQKeyboardManagerSwift
import UIKit

final class SchoolInfoViewController: UIViewController {
    // MARK: - UI Elements

    let firstParentNumberTextField = NoCutPasteTextField()
    let secondParentNumberTextField = NoCutPasteTextField()
    let schoolNameTextField = NoCutPasteTextField()
    let academicTypeTextField = NoCutPasteTextField()
    let academicDivisionTextField = NoCutPasteTextField()
    let academicYearTextField = NoCutPasteTextField()
    let fieldTextField = NoCutPasteTextField()

    // MARK: - Pickers

    let academicTypesPickerView = PickerInputView<String>(height: 200)
    let divisionsPickerView = PickerInputView<String>(height: 200)
    let academicYearPickerView = PickerInputView<String>(height: 200)
    let fieldsPickerView = PickerInputView<String>(height: 200)

    // MARK: - Dependencies

    let errorDisplay = FormErrorDisplay()
    let fieldLoadingIndicator = TextFieldLoadingIndicator()
    private var pickerCoordinator: SchoolPickerCoordinator?
    private unowned let viewModel: AcademicInfoViewModel

    // MARK: - Init

    init(viewModel: AcademicInfoViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("Use init(viewModel:)") }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupLayout()
        configureFields()
        setupPickerCoordinator()
        errorDisplay.attachErrorLabels(to: [
            firstParentNumberTextField, schoolNameTextField,
            academicTypeTextField, academicDivisionTextField, academicYearTextField
        ])
    }

    // MARK: - Public Interface

    func collectValues() -> SchoolFieldValues {
        SchoolFieldValues(
            parentNumber: firstParentNumberTextField.text ?? "",
            parentNumber2: secondParentNumberTextField.text ?? "",
            schoolName: schoolNameTextField.text ?? ""
        )
    }

    func restoreData() {
        let values = viewModel.restoreSchoolData()
        firstParentNumberTextField.text = values.parentNumber
        secondParentNumberTextField.text = values.parentNumber2
        schoolNameTextField.text = values.schoolName
    }

    func clearData() {
        viewModel.clearSchoolData()
        firstParentNumberTextField.text = ""
        secondParentNumberTextField.text = ""
        [schoolNameTextField, academicTypeTextField, academicDivisionTextField, academicYearTextField, fieldTextField]
            .forEach { $0.text = "" }
        errorDisplay.clearAll()
    }

    func showValidationErrors(_ errors: [RegistrationValidationError]) {
        errorDisplay.clearAll()
        for error in errors {
            switch error {
            case .parentNumberInvalid:
                firstParentNumberTextField.setErrorView()
                errorDisplay.showError(for: firstParentNumberTextField, message: error.localizedMessage)
            case .schoolNameEmpty:
                schoolNameTextField.setErrorView()
                errorDisplay.showError(for: schoolNameTextField, message: error.localizedMessage)
            case .academicTypeMissing:
                academicTypeTextField.setErrorView()
                errorDisplay.showError(for: academicTypeTextField, message: error.localizedMessage)
            case .divisionMissing:
                academicDivisionTextField.setErrorView()
                errorDisplay.showError(for: academicDivisionTextField, message: error.localizedMessage)
            default:
                continue
            }
        }
    }

    func saveState() {
        viewModel.saveStateToStore(schoolValues: collectValues())
    }

    // MARK: - Data Loading

    func loadAcademicTypes() {
        guard !AppEnvironment.shouldHideOrganizationAndSchool else { return }
        fieldLoadingIndicator.showLoading(on: academicTypeTextField)
        Task { [weak self] in
            guard let self else { return }
            _ = await viewModel.loadAcademicTypes()
            await MainActor.run { [weak self] in
                guard let self else { return }
                fieldLoadingIndicator.hideLoading(on: academicTypeTextField)
                academicTypeTextField.text = viewModel.selectedAcademicType?.value
                retrieveAcademicDivisions()
            }
        }
    }

    func retrieveAcademicDivisions() {
        guard !AppEnvironment.shouldHideOrganizationAndSchool else { return }
        fieldLoadingIndicator.showLoading(on: academicDivisionTextField)
        Task { [weak self] in
            guard let self else { return }
            _ = await viewModel.loadAcademicDivisions()
            await MainActor.run { [weak self] in
                guard let self else { return }
                fieldLoadingIndicator.hideLoading(on: academicDivisionTextField)
                academicDivisionTextField.text = viewModel.selectedDivision?.value
                retrieveAcademicYear()
                retrieveSchoolFields()
            }
        }
    }

    func retrieveAcademicYear() {
        fieldLoadingIndicator.showLoading(on: academicYearTextField)
        Task { [weak self] in
            guard let self else { return }
            _ = await viewModel.loadAcademicYear()
            await MainActor.run { [weak self] in
                guard let self else { return }
                fieldLoadingIndicator.hideLoading(on: academicYearTextField)
                academicYearTextField.text = viewModel.academicYears[safe: viewModel.selectedYearIndex]?.value
            }
        }
    }

    func retrieveSchoolFields() {
        fieldLoadingIndicator.showLoading(on: fieldTextField)
        Task { [weak self] in
            guard let self else { return }
            _ = await viewModel.loadSchoolFields()
            await MainActor.run { [weak self] in
                guard let self else { return }
                fieldLoadingIndicator.hideLoading(on: fieldTextField)
                fieldTextField.text = viewModel.selectedSchoolField?.value ?? L10n.Signup.School.none
                viewModel.onFormDidChange?()
            }
        }
    }

    // MARK: - Private Setup

    private func setupLayout() {
        let allFields: [UIView] = [
            firstParentNumberTextField, secondParentNumberTextField, schoolNameTextField,
            academicTypeTextField, academicDivisionTextField, academicYearTextField, fieldTextField
        ]
        allFields.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.heightAnchor.constraint(equalToConstant: 50).isActive = true
        }
        let stack = UIStackView(arrangedSubviews: allFields)
        stack.axis = .vertical
        stack.spacing = 28
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func configureFields() {
        RegistrationFieldConfigurer.configureMandatory(firstParentNumberTextField, placeholder: L10n.Signup.School.parentNumber)
        RegistrationFieldConfigurer.configureOptional(secondParentNumberTextField, placeholder: L10n.Signup.School.parentNumber2)
        RegistrationFieldConfigurer.configureMandatory(schoolNameTextField, placeholder: L10n.Signup.School.schoolName)
        RegistrationFieldConfigurer.configurePickerField(academicTypeTextField, placeholder: L10n.Signup.School.academicType, picker: academicTypesPickerView)
        RegistrationFieldConfigurer.configurePickerField(academicDivisionTextField, placeholder: L10n.Signup.School.academicDivision, picker: divisionsPickerView)
        RegistrationFieldConfigurer.configurePickerField(academicYearTextField, placeholder: L10n.Signup.School.academicYear, picker: academicYearPickerView)
        RegistrationFieldConfigurer.configurePickerField(fieldTextField, placeholder: L10n.Signup.School.field, picker: fieldsPickerView)
        fieldTextField.isMandatoryTextField = false

        let allFields: [UITextField] = [
            firstParentNumberTextField, secondParentNumberTextField, schoolNameTextField,
            academicTypeTextField, academicDivisionTextField, academicYearTextField, fieldTextField
        ]
        allFields.forEach { $0.delegate = self }
        [firstParentNumberTextField, secondParentNumberTextField]
            .forEach { $0.addTarget(self, action: #selector(parentPhoneDidChange(_:)), for: .editingChanged) }
        schoolNameTextField.addTarget(self, action: #selector(liveValidateField(_:)), for: .editingChanged)
    }

    private func setupPickerCoordinator() {
        pickerCoordinator = SchoolPickerCoordinator(
            viewModel: viewModel,
            schoolVC: self,
            academicTypesPicker: academicTypesPickerView,
            divisionsPicker: divisionsPickerView,
            academicYearPicker: academicYearPickerView,
            fieldsPicker: fieldsPickerView
        )
        pickerCoordinator?.configure(
            with: SchoolPickerCoordinator.TextFields(
                academicType: academicTypeTextField,
                academicDivision: academicDivisionTextField,
                academicYear: academicYearTextField,
                field: fieldTextField
            )
        )
    }

    @objc
    private func parentPhoneDidChange(_ sender: UITextField) {
        viewModel.onFormDidChange?()
        saveState()
    }

    @objc
    private func liveValidateField(_ sender: UITextField) {
        viewModel.onFormDidChange?()
        errorDisplay.clearError(for: sender)
        saveState()
        if let error = viewModel.validateField(
            .schoolName,
            parentNumber: firstParentNumberTextField.text ?? "",
            schoolName: schoolNameTextField.text ?? ""
        ) {
            sender.setBorder(color: .red, width: 1, cornerRadius: 6)
            errorDisplay.showError(for: sender, message: error.localizedMessage)
        }
    }
}

// MARK: - UITextFieldDelegate

extension SchoolInfoViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        viewModel.onFormDidChange?()
    }
}
