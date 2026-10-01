// Copyright © 2026 Pharos Solutions. All rights reserved.

import IQKeyboardManagerSwift
import UIKit

final class UniversityInfoViewController: UIViewController {
    // MARK: - UI Elements

    let studentButton = UIButton(type: .system)
    let graduateButton = UIButton(type: .system)
    let universityTextField = NoCutPasteTextField()
    let uniFieldTextField = NoCutPasteTextField()
    let uniYearTextField = NoCutPasteTextField()
    let activityIndicator = UIActivityIndicatorView(style: .medium)

    // MARK: - Pickers

    let universityPickerView = PickerInputView<String>(height: 200)
    let uniFieldPickerView = PickerInputView<String>(height: 200)
    let uniYearPickerView = PickerInputView<String>(height: 200)

    // MARK: - Constraints

    private(set) var uniFieldHeightConstraint: NSLayoutConstraint!
    private(set) var uniYearHeightConstraint: NSLayoutConstraint!

    // MARK: - State

    private(set) var isFieldsVisible: Bool = false

    // MARK: - Dependencies

    let errorDisplay = FormErrorDisplay()
    let fieldLoadingIndicator = TextFieldLoadingIndicator()
    private var pickerCoordinator: UniversityPickerCoordinator?
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
        configureButtons()
        configureFields()
        setupPickerCoordinator()
        errorDisplay.attachErrorLabels(to: [universityTextField, uniYearTextField])
    }

    // MARK: - Sub-tab Configuration

    func configureStudentView() {
        graduateButton.layer.backgroundColor = Colors.backgroundLightGreyColor.color.cgColor
        graduateButton.setTitleColor(.black, for: .normal)
        studentButton.layer.backgroundColor = Colors.backgroundLightPurple.color.cgColor
        studentButton.setTitleColor(Colors.sendButtonColor.color, for: .normal)
        uniYearTextField.isHidden = false
        uniYearHeightConstraint.constant = 50
    }

    func configureGraduateView() {
        studentButton.layer.backgroundColor = Colors.backgroundLightGreyColor.color.cgColor
        studentButton.setTitleColor(.black, for: .normal)
        graduateButton.layer.backgroundColor = Colors.backgroundLightPurple.color.cgColor
        graduateButton.setTitleColor(Colors.sendButtonColor.color, for: .normal)
        uniYearTextField.isHidden = true
        uniYearHeightConstraint.constant = 0
    }

    func configureSubTabsUnselected() {
        [studentButton, graduateButton].forEach {
            $0.layer.backgroundColor = Colors.backgroundLightGreyColor.color.cgColor
            $0.setTitleColor(.black, for: .normal)
        }
    }

    // MARK: - Field Visibility

    func showFieldsImmediately() {
        isFieldsVisible = true
        [universityTextField, uniFieldTextField, uniYearTextField].forEach { $0.alpha = 1 }
        universityTextField.isHidden = false
        uniFieldTextField.isHidden = uniFieldHeightConstraint.constant == 0
        uniYearTextField.isHidden = uniYearHeightConstraint.constant == 0
        view.layoutIfNeeded()
    }

    func hideFields() {
        isFieldsVisible = false
        [universityTextField, uniFieldTextField, uniYearTextField].forEach {
            $0.alpha = 0
            $0.isHidden = true
        }
    }

    func fadeFieldsIn() {
        guard !isFieldsVisible else { return }
        isFieldsVisible = true
        let fields: [UITextField] = [universityTextField, uniFieldTextField, uniYearTextField]
        fields.forEach { $0.alpha = 0 }
        universityTextField.isHidden = false
        uniFieldTextField.isHidden = uniFieldHeightConstraint.constant == 0
        uniYearTextField.isHidden = uniYearHeightConstraint.constant == 0
        UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseIn) {
            fields.forEach { $0.alpha = 1 }
        }
    }

    // MARK: - State Management

    func restoreData() {
        let values = viewModel.restoreUniversityData()
        universityTextField.text = values.universityName
        uniFieldTextField.text = values.uniFieldName
        uniYearTextField.text = values.uniYearName
    }

    func resetData() {
        universityTextField.text = ""
        uniFieldTextField.text = ""
        uniYearTextField.text = ""
        viewModel.resetUniSelection()
        hideFields()
    }

    func clearData() {
        resetData()
        viewModel.clearUniversityData()
        errorDisplay.clearAll()
    }

    func showValidationErrors(_ errors: [RegistrationValidationError]) {
        errorDisplay.clearAll()
        for error in errors {
            switch error {
            case .universityMissing:
                universityTextField.setErrorView()
                errorDisplay.showError(for: universityTextField, message: error.localizedMessage)
            case .universityYearMissing:
                uniYearTextField.setErrorView()
                errorDisplay.showError(for: uniYearTextField, message: error.localizedMessage)
            default:
                continue
            }
        }
    }

    // MARK: - Data Loading

    func retrieveUniversities() {
        if viewModel.isRoyalMedicine {
            universityTextField.text = GlobalConstants.facultyOfMedicineSpecializationAndDivision.value
            uniFieldTextField.text = GlobalConstants.facultyOfMedicineSpecializationAndDivision.value
            retrieveUniYearsOnly()
            fadeFieldsIn()
            activityIndicator.stopAnimating()
            return
        }
        fieldLoadingIndicator.showLoading(on: universityTextField)
        Task { [weak self] in
            guard let self else { return }
            let unis = await viewModel.loadUniversities()
            await MainActor.run { [weak self] in
                guard let self = self else { return }
                self.fieldLoadingIndicator.hideLoading(on: universityTextField)
                if let first = unis.first { universityTextField.text = first.value }
                retrieveUniFieldsAndYears()
            }
        }
    }

    func retrieveUniFieldsAndYears() {
        fieldLoadingIndicator.showLoading(on: uniFieldTextField)
        fieldLoadingIndicator.showLoading(on: uniYearTextField)
        Task { [weak self] in
            guard let self else { return }
            let viewModel = self.viewModel
            let result = await viewModel.loadUniFieldsAndYears()
            await MainActor.run { [weak self] in
                guard let self else { return }
                fieldLoadingIndicator.hideLoading(on: uniFieldTextField)
                fieldLoadingIndicator.hideLoading(on: uniYearTextField)
                if viewModel.uniFields.isEmpty {
                    uniFieldTextField.isHidden = true
                    uniFieldHeightConstraint.constant = 0
                } else {
                    uniFieldTextField.isHidden = false
                    uniFieldHeightConstraint.constant = 50
                    uniFieldTextField.text = viewModel.uniFields[safe: viewModel.selectedUniFieldIndex]?.value
                }
                uniYearTextField.text = viewModel.uniYears[safe: viewModel.selectedUniYearIndex]?.value
                activityIndicator.stopAnimating()
                fadeFieldsIn()
                viewModel.onFormDidChange?()
            }
        }
    }

    func retrieveUniYearsOnly() {
        Task { [weak self] in
            guard let self else { return }
            let viewModel = self.viewModel
            _ = await viewModel.loadUniYearsOnly()
            await MainActor.run { [weak self] in
                guard let self else { return }
                uniYearTextField.text = viewModel.uniYears[safe: viewModel.selectedUniYearIndex]?.value
                viewModel.onFormDidChange?()
            }
        }
    }

    // MARK: - Button Actions

    @objc
    private func didChooseStudent() {
        let wasAlreadyChosen = viewModel.hasChosenAcademicLevel
        viewModel.academicLevel = .universityStudent
        viewModel.hasChosenAcademicLevel = true
        if !wasAlreadyChosen {
            hideFields()
            activityIndicator.startAnimating()
            viewModel.onRequestContainerResize?(336) { [weak self] in
                guard let self else { return }
                configureStudentView()
                retrieveUniversities()
            }
        } else {
            configureStudentView()
            if viewModel.universities.isEmpty { retrieveUniversities() }
            fadeFieldsIn()
        }
        viewModel.onFormDidChange?()
    }

    @objc
    private func didChooseGraduate() {
        let wasAlreadyChosen = viewModel.hasChosenAcademicLevel
        viewModel.academicLevel = .graduate
        viewModel.hasChosenAcademicLevel = true
        if !wasAlreadyChosen {
            hideFields()
            activityIndicator.startAnimating()
            viewModel.onRequestContainerResize?(286) { [weak self] in
                guard let self else { return }
                configureGraduateView()
                retrieveUniversities()
            }
        } else {
            configureGraduateView()
            if viewModel.universities.isEmpty { retrieveUniversities() }
            fadeFieldsIn()
        }
        viewModel.onFormDidChange?()
    }

    // MARK: - Private Setup

    private func setupLayout() {
        let buttonsStack = UIStackView(arrangedSubviews: [studentButton, graduateButton])
        buttonsStack.axis = .horizontal
        buttonsStack.spacing = 12
        buttonsStack.distribution = .fillEqually
        buttonsStack.translatesAutoresizingMaskIntoConstraints = false
        buttonsStack.heightAnchor.constraint(equalToConstant: 44).isActive = true

        [universityTextField, uniFieldTextField, uniYearTextField].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        universityTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        uniFieldHeightConstraint = uniFieldTextField.heightAnchor.constraint(equalToConstant: 50)
        uniFieldHeightConstraint.isActive = true
        uniYearHeightConstraint = uniYearTextField.heightAnchor.constraint(equalToConstant: 50)
        uniYearHeightConstraint.isActive = true

        let fieldsStack = UIStackView(arrangedSubviews: [universityTextField, uniFieldTextField, uniYearTextField])
        fieldsStack.axis = .vertical
        fieldsStack.spacing = 28

        let mainStack = UIStackView(arrangedSubviews: [buttonsStack, fieldsStack])
        mainStack.axis = .vertical
        mainStack.spacing = 28
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainStack)

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            mainStack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func configureButtons() {
        studentButton.setTitle(L10n.Signup.UniversityScreen.student, for: .normal)
        studentButton.layer.cornerRadius = UIConstants.slightCornerRadius
        studentButton.titleLabel?.font = FontFamily.Inter.regular.font(size: 14)
        studentButton.isEnabled = AppEnvironment.appName != .royalMedicine
        studentButton.addTarget(self, action: #selector(didChooseStudent), for: .touchUpInside)

        graduateButton.setTitle(L10n.Signup.UniversityScreen.graduate, for: .normal)
        graduateButton.layer.cornerRadius = UIConstants.slightCornerRadius
        graduateButton.titleLabel?.font = FontFamily.Inter.regular.font(size: 14)
        graduateButton.isHidden = AppEnvironment.shouldHideOrganizationAndSchool
        graduateButton.addTarget(self, action: #selector(didChooseGraduate), for: .touchUpInside)

        configureSubTabsUnselected()
    }

    private func configureFields() {
        RegistrationFieldConfigurer.configureUniField(universityTextField, placeholder: L10n.Signup.UniversityScreen.university, picker: universityPickerView)
        RegistrationFieldConfigurer.configureUniField(uniFieldTextField, placeholder: L10n.Signup.UniversityScreen.field, picker: uniFieldPickerView)
        RegistrationFieldConfigurer.configurePickerField(uniYearTextField, placeholder: L10n.Signup.UniversityScreen.year, picker: uniYearPickerView)
        [universityTextField, uniFieldTextField, uniYearTextField].forEach { $0.delegate = self }
    }

    private func setupPickerCoordinator() {
        pickerCoordinator = UniversityPickerCoordinator(
            viewModel: viewModel,
            universityVC: self,
            universityPicker: universityPickerView,
            uniFieldPicker: uniFieldPickerView,
            uniYearPicker: uniYearPickerView
        )
        pickerCoordinator?.configure(with: UniversityPickerCoordinator.TextFields(
            university: universityTextField,
            uniField: uniFieldTextField,
            uniYear: uniYearTextField
        ))
    }
}

// MARK: - UITextFieldDelegate

extension UniversityInfoViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        viewModel.onFormDidChange?()
    }
}
