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
    private var divisionsList: [String] = []
    private var academicYears: [String] = []
    private var divisionsPickerView = PickerInputView<String>(height: 200)
    private var academicTypesPickerView = PickerInputView<String>(height: 200)
    private var academicYearPickerView = PickerInputView<String>(height: 200)
    private var selectedDivision: Division?

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
        divisionsPickerView.items = { self.divisionsList }
        academicTypesPickerView.items = { (self.academicTypesList?.compactMap { $0.value } ?? [""]) }
        academicYearPickerView.items = { self.academicYears }

        academicTypeTextField.keyboardToolbar.doneBarButton.setTarget(self, action: #selector(academicTypePickerDoneTapped))
        academicDivisionTextField.keyboardToolbar.doneBarButton.setTarget(self, action: #selector(academicDivisionPickerDoneTapped))
        academicYearTextField.keyboardToolbar.doneBarButton.setTarget(self, action: #selector(academicYearPickerDoneTapped))
    }

    private func configurePickerViews() {
        divisionsPickerView.text = { $0 }
        academicTypesPickerView.text = { $0 }
        academicYearPickerView.text = { $0 }

        divisionsPickerView.didSelectAtIndex = { [unowned self] index in
            academicDivisionTextField.text = self.divisionsList[index]
            self.selectedDivisionIndexID = index
            self.selectedDivision = viewModel?.divisions?[index]
            academicDivisionTextField.setNormalView()
        }
        academicTypesPickerView.didSelectAtIndex = { [unowned self] index in
            selectedAcademicType = academicTypesList?[index]
            academicTypeTextField.text = selectedAcademicType?.value
            academicTypeTextField.setNormalView()
        }
        academicYearPickerView.didSelectAtIndex = { [unowned self] index in
            guard !academicYears.isEmpty else { return }
            academicYearTextField.text = self.academicYears[index]
            self.selectedYearIndexID = index
            academicYearTextField.setNormalView()
        }
    }

    private func loadAcademicTypes() {
        viewModel?.loadAcademicTypes(for: .schoolStudent) { academicTypes in
            self.academicTypesList = academicTypes
        }
    }

    private func retrieveAcademicDivisions() {
        activityIndicator.startAnimating()
        viewModel?.loadAcademicDivisions(for: .schoolStudent, in: self.selectedAcademicType?.key ?? 0) { divisions in
            self.activityIndicator.stopAnimating()
            self.divisionsList = divisions
        }
    }

    private func retrieveAcademicYear() {
        activityIndicator.startAnimating()
        viewModel?.loadBatches(for: selectedDivision?.key ?? 0) { batches in
            self.activityIndicator.stopAnimating()
            self.academicYears = batches
        }
    }

    @objc
    private func academicTypePickerDoneTapped() {
        if selectedAcademicType == nil {
            selectedAcademicType = academicTypesList?[0]
        }
        academicTypesPickerView.resignFirstResponder()
        academicTypeTextField.text = selectedAcademicType?.value
        retrieveAcademicDivisions()
    }

    @objc
    private func academicDivisionPickerDoneTapped() {
        divisionsPickerView.resignFirstResponder()
        User.shared.divisionId = selectedDivision?.key
        academicDivisionTextField.text = selectedDivision?.value
        retrieveAcademicYear()
    }

    @objc
    private func academicYearPickerDoneTapped() {
        guard !academicYears.isEmpty else { return }
        academicYearPickerView.resignFirstResponder()
        academicYearTextField.text = academicYears[selectedYearIndexID]
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
        User.shared.batch = academicYearTextField.isEmpty ? nil : viewModel?.batchesIDs[selectedYearIndexID]
        User.shared.batchName = academicYearTextField.text
        User.shared.schoolName = schoolNameTextField.text
    }

    private func displayAlreadyEnteredDataIfAny() {
        firstParentNumberTextField.text = User.shared.parentNumber
        secondParentNumberTextField.text = User.shared.parentNumber2
        academicTypeTextField.text = User.shared.academicTypeName
        academicDivisionTextField.text = User.shared.divisionName
        academicYearTextField.text = User.shared.batchName
        schoolNameTextField.text = User.shared.schoolName
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
