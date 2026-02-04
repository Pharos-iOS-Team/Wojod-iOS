// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit

class SchoolViewController: UIViewController {
    // MARK: - IBOutlets

    @IBOutlet private var schoolLabel: UILabel! {
        didSet {
            schoolLabel.text = L10n.Signup.AcademicInfo.school
        }
    }
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
    @IBOutlet private var firstParentNumberTextField: NoCutPasteTextField! {
        didSet {
            firstParentNumberTextField.isMandatoryTextField = true
            firstParentNumberTextField.placeholder = L10n.Signup.School.parentNumber
            firstParentNumberTextField.semanticContentAttribute = Language.semanticContent
            firstParentNumberTextField.textAlignment = Language.textAlignment
        }
    }
    @IBOutlet private var secondParentNumberTextField: UITextField! {
        didSet {
            secondParentNumberTextField.placeholder = L10n.Signup.School.parentNumber2
            secondParentNumberTextField.semanticContentAttribute = Language.semanticContent
            secondParentNumberTextField.textAlignment = Language.textAlignment
        }
    }
    @IBOutlet private var schoolNameTextField: NoCutPasteTextField! {
        didSet {
            schoolNameTextField.isMandatoryTextField = true
            schoolNameTextField.placeholder = L10n.Signup.School.schoolName
            schoolNameTextField.semanticContentAttribute = Language.semanticContent
            schoolNameTextField.textAlignment = Language.textAlignment
        }
    }
    @IBOutlet private var academicTypeTextField: NoCutPasteTextField! {
        didSet {
            academicTypeTextField.placeholder = L10n.Signup.School.academicType
            academicTypeTextField.addRightIcon(Images.path.image, width: 10, height: 6)
            academicTypeTextField.inputView = academicTypesPickerView
            academicTypeTextField.isMandatoryTextField = true
            academicTypeTextField.semanticContentAttribute = Language.semanticContent
            academicTypeTextField.textAlignment = Language.textAlignment
        }
    }
    @IBOutlet private var academicDivisionTextField: NoCutPasteTextField! {
        didSet {
            academicDivisionTextField.placeholder = L10n.Signup.School.academicDivision
            academicDivisionTextField.addRightIcon(Images.path.image, width: 10, height: 6)
            academicDivisionTextField.inputView = divisionsPickerView
            academicDivisionTextField.isMandatoryTextField = true
            academicDivisionTextField.semanticContentAttribute = Language.semanticContent
            academicDivisionTextField.textAlignment = Language.textAlignment
        }
    }
    @IBOutlet private var academicYearTextField: NoCutPasteTextField! {
        didSet {
            academicYearTextField.placeholder = L10n.Signup.School.academicYear
            academicYearTextField.addRightIcon(Images.path.image, width: 10, height: 6)
            academicYearTextField.inputView = academicYearPickerView
            academicYearTextField.isMandatoryTextField = true
            academicYearTextField.semanticContentAttribute = Language.semanticContent
            academicYearTextField.textAlignment = Language.textAlignment
        }
    }
    @IBOutlet private var fieldTextField: NoCutPasteTextField! {
        didSet {
            fieldTextField.addRightIcon(Images.path.image, width: 10, height: 6)
            fieldTextField.isMandatoryTextField = false
            fieldTextField.placeholder = L10n.Signup.School.field
            fieldTextField.inputView = fieldsPickerView
            fieldTextField.semanticContentAttribute = Language.semanticContent
            fieldTextField.textAlignment = Language.textAlignment
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
    @IBOutlet private var nextButton: SendButton! {
        didSet {
            nextButton.isEnabled = false
        }
    }
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!

    // MARK: - Private Properties

    private var viewModel: RegistrationViewModel?
    private var selectedAcademicType: KeyValue?
    private var academicTypesList: [KeyValue]?
    private var selectedDivisionIndexID: Int = 0
    private var selectedYearIndexID: Int = 0
    private var divisionsList: [Division] = []
    private var academicYears: [Batch] = []
    private var fields: [Specialization] = []
    private var divisionsPickerView = PickerInputView<String>(height: 200)
    private var academicTypesPickerView = PickerInputView<String>(height: 200)
    private var academicYearPickerView = PickerInputView<String>(height: 200)
    private var fieldsPickerView = PickerInputView<String>(height: 200)
    private var selectedDivision: Division?
    private var selectedField: Specialization?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = RegistrationViewModel()
        configureSemanticAttribute()
        loadAcademicTypes()
        configurePickerFields()
        configurePickerViews()
        displayAlreadyEnteredDataIfAny()
        configureTextFieldsDelegate()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideWrongCredentials()
        nextButton.backgroundColor = Colors.darkGreyColor.color
    }

    // MARK: - IBActions

    @IBAction private func didTapOnBack(_ sender: UIButton) {
        retrieveInputEnteredFromUser()
        self.dismiss(animated: false)
    }

    // MARK: - Private Functions

    private func configurePickerFields() {
        divisionsPickerView.items = { self.divisionsList.compactMap { $0.value } }
        academicTypesPickerView.items = { (self.academicTypesList?.compactMap { $0.value } ?? [""]) }
        academicYearPickerView.items = { self.academicYears.compactMap { $0.value } }
        fieldsPickerView.items = { self.fields.compactMap { $0.value } }

        academicTypeTextField.iq.toolbar.doneBarButton.setTarget(self, action: #selector(academicTypePickerDoneTapped))
        academicDivisionTextField.iq.toolbar.doneBarButton.setTarget(self, action: #selector(academicDivisionPickerDoneTapped))
        academicYearTextField.iq.toolbar.doneBarButton.setTarget(self, action: #selector(academicYearPickerDoneTapped))
        fieldTextField.iq.toolbar.doneBarButton.setTarget(self, action: #selector(fieldPickerDoneTapped))
    }

    // swiftlint:disable function_body_length
    private func configurePickerViews() {
        divisionsPickerView.text = { $0 }
        academicTypesPickerView.text = { $0 }
        academicYearPickerView.text = { $0 }
        fieldsPickerView.text = { $0 }

        divisionsPickerView.didSelectAtIndex = { [unowned self] index in
            academicDivisionTextField.text = self.divisionsList[safe: index]?.value
            self.selectedDivisionIndexID = index
            self.selectedDivision = viewModel?.divisions?[safe: index]
            academicDivisionTextField.setNormalView()
        }
        academicTypesPickerView.didSelectAtIndex = { [unowned self] index in
            selectedAcademicType = academicTypesList?[safe: index]
            academicTypeTextField.text = selectedAcademicType?.value
            academicTypeTextField.setNormalView()
        }
        academicYearPickerView.didSelectAtIndex = { [unowned self] index in
            guard !academicYears.isEmpty else { return }
            academicYearTextField.text = self.academicYears[safe: index]?.value
            self.selectedYearIndexID = index
            academicYearTextField.setNormalView()
        }
        fieldsPickerView.didSelectAtIndex = { [unowned self] index in
            fieldTextField.text = self.fields[safe: index]?.value
            selectedField = self.fields[safe: index]
            fieldTextField.setNormalView()
        }
    }

    private func loadAcademicTypes() {
        viewModel?.loadAcademicTypes(for: .schoolStudent) { academicTypes in
            self.academicTypesList = academicTypes
            self.selectedAcademicType = academicTypes?.first
            self.academicTypeTextField.text = academicTypes?.first?.value
            self.retrieveAcademicDivisions()
        }
    }

    private func retrieveAcademicDivisions() {
        activityIndicator.startAnimating()
        viewModel?.loadAcademicDivisions(for: .schoolStudent, in: self.selectedAcademicType?.key ?? 0) { divisions in
            self.activityIndicator.stopAnimating()
            self.divisionsList = divisions ?? []
            User.shared.divisionId = divisions?.first?.key
            User.shared.divisionName = divisions?.first?.value
            self.academicDivisionTextField.text = divisions?.first?.value
            self.selectedDivision = divisions?.first
            self.retrieveAcademicYear()
            self.retrieveFields()
        }
    }

    private func retrieveAcademicYear() {
        activityIndicator.startAnimating()
        viewModel?.loadBatches(for: selectedDivision?.key ?? 0) { batches in
            self.activityIndicator.stopAnimating()
            self.academicYears = batches ?? []
            self.selectedYearIndexID = 0
            self.academicYearTextField.text = batches?.first?.value ?? L10n.Signup.School.none
            if batches?.isEmpty ?? true {
                self.academicYears.append(Batch(key: nil, value: L10n.Signup.School.none))
            }
        }
    }

    private func retrieveFields() {
        activityIndicator.startAnimating()
        viewModel?.loadSpecializations(for: selectedDivision?.key ?? 0) { fields in
            self.activityIndicator.stopAnimating()
            self.fields = fields ?? []
            self.fieldTextField.text = L10n.Signup.School.none
            self.fields.append(Specialization(key: nil, value: L10n.Signup.School.none))
        }
    }

    @objc
    private func academicTypePickerDoneTapped() {
        if selectedAcademicType == nil {
            selectedAcademicType = academicTypesList?.first
        }
        academicTypesPickerView.resignFirstResponder()
        academicTypeTextField.text = selectedAcademicType?.value
        retrieveAcademicDivisions()
    }

    @objc
    private func academicDivisionPickerDoneTapped() {
        if selectedDivision == nil {
            selectedDivision = viewModel?.divisions?.first
        }
        divisionsPickerView.resignFirstResponder()
        User.shared.divisionId = selectedDivision?.key
        academicDivisionTextField.text = selectedDivision?.value
        retrieveAcademicYear()
        retrieveFields()
    }

    @objc
    private func academicYearPickerDoneTapped() {
        guard !academicYears.isEmpty else { return }
        academicYearPickerView.resignFirstResponder()
        academicYearTextField.text = academicYears[safe: selectedYearIndexID]?.value
    }

    @objc
    private func fieldPickerDoneTapped() {
        if selectedField == nil {
            selectedField = fields.first
        }
        fieldsPickerView.resignFirstResponder()
        User.shared.specializationId = selectedField?.key
        fieldTextField.text = selectedField?.value
    }

    private func isMandatoryFieldsFilled() -> Bool {
        return !firstParentNumberTextField.isEmpty && !academicTypeTextField.isEmpty && !academicDivisionTextField.isEmpty &&
        !academicYearTextField.isEmpty && !schoolNameTextField.isEmpty
    }

    private func isFirstNumberValid() -> Bool {
        if firstParentNumberTextField.text?.count == 11 {
            return true
        } else {
            firstParentNumberTextField.setErrorView()
            return false
        }
    }

    private func configureEmptyMandatoryFields() {
        if firstParentNumberTextField.isEmpty {
            firstParentNumberTextField.setErrorView()
        }
        if academicTypeTextField.isEmpty {
            academicTypeTextField.setErrorView()
        }
        if academicDivisionTextField.isEmpty {
            academicDivisionTextField.setErrorView()
        }
        if academicYearTextField.isEmpty {
            academicYearTextField.setErrorView()
        }
        if schoolNameTextField.isEmpty {
            schoolNameTextField.setErrorView()
        }
    }

    private func retrieveInputEnteredFromUser() {
        User.shared.educationLevel = 0
        User.shared.parentNumber = firstParentNumberTextField.text
        User.shared.parentNumber2 = secondParentNumberTextField.text
        User.shared.academicType = selectedAcademicType?.key
        User.shared.academicTypeName = academicTypeTextField.text
        User.shared.divisionId = selectedDivision?.key ?? 0
        User.shared.divisionName = academicDivisionTextField.text
        User.shared.batch = academicYearTextField.isEmpty ? nil : viewModel?.batchesIDs[safe: selectedYearIndexID]
        User.shared.batchName = academicYearTextField.text
        User.shared.schoolName = schoolNameTextField.text
        User.shared.specializationId = selectedField?.key
        User.shared.specializationName = selectedField?.value == "None" ? nil : selectedField?.value
    }

    private func displayAlreadyEnteredDataIfAny() {
        firstParentNumberTextField.text = User.shared.parentNumber
        secondParentNumberTextField.text = User.shared.parentNumber2
        academicTypeTextField.text = User.shared.academicTypeName
        academicYearTextField.text = User.shared.batchName
        schoolNameTextField.text = User.shared.schoolName
        fieldTextField.text = User.shared.specializationName ?? ""
    }

    private func showWrongCredentials() {
        wrongCredentialsImageView.isHidden = false
        wrongCredentialsImageViewHeight.constant = 50.0
    }

    private func hideWrongCredentials() {
        wrongCredentialsImageView.isHidden = true
        wrongCredentialsImageViewHeight.constant = 0
    }

    private func configureTextFieldsDelegate() {
        firstParentNumberTextField.delegate = self
        academicTypeTextField.delegate = self
        academicDivisionTextField.delegate = self
        academicYearTextField.delegate = self
        schoolNameTextField.delegate = self
    }

    // MARK: - Segue

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        guard isMandatoryFieldsFilled(), isFirstNumberValid() else {
            showWrongCredentials()
            configureEmptyMandatoryFields()
            return false
        }
        return true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        retrieveInputEnteredFromUser()
    }
}

// MARK: - Text Field Delegate

extension SchoolViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if isMandatoryFieldsFilled() {
            nextButton.isEnabled = true
            nextButton.backgroundColor = Colors.sendButtonColor.color
        } else {
            nextButton.isEnabled = false
            nextButton.backgroundColor = Colors.darkGreyColor.color
        }
    }
}
