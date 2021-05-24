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

    // MARK: - Private Properties

    private var viewModel: RegistrationViewModel?
    private var selectedAcademicTypeIndexID: Int = 0
    private var selectedDivisionIndexID: Int = 0
    private var selectedYearIndexID: Int = 0
    private var divisionsList: [String] = []
    private var academicTypesList: [String] = []
    private var academicYears: [String] = []
    private var divisionsPickerView = PickerInputView<String>(height: 200)
    private var academicTypesPickerView = PickerInputView<String>(height: 200)
    private var academicYearPickerView = PickerInputView<String>(height: 200)

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = RegistrationViewModel()
        configureSemanticAttribute()
        loadAcademicTypes()
        retrieveAcademicDivisions()
        configurePickerFields()
        configurePickerViews()
        displayAlreadyEnteredDataIfAny()
    }

    // MARK: - IBActions

    @IBAction private func didTapOnBack(_ sender: UIButton) {
        retrieveInputEnteredFromUser()
        self.dismiss(animated: false)
    }

    // MARK: - Private Functions

    private func configurePickerFields() {
        divisionsPickerView.items = { self.divisionsList }
        academicTypesPickerView.items = { self.academicTypesList }
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
            academicDivisionTextField.setNormalView()
        }
        academicTypesPickerView.didSelectAtIndex = { [unowned self] index in
            academicTypeTextField.text = self.academicTypesList[index]
            self.selectedAcademicTypeIndexID = index
            academicTypeTextField.setNormalView()
        }
        academicYearPickerView.didSelectAtIndex = { [unowned self] index in
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
        viewModel?.loadAcademicDivisions(for: .schoolStudent) { divisions in
            self.divisionsList = divisions
        }
    }

    private func retrieveAcademicYear() {
        viewModel?.loadBatches(for: User.shared.divisionId ?? 0 ) { batches in
            self.academicYears = batches
        }
    }

    @objc
    private func academicTypePickerDoneTapped() {
        academicTypesPickerView.resignFirstResponder()
        academicTypeTextField.text = academicTypesList[selectedAcademicTypeIndexID]
    }

    @objc
    private func academicDivisionPickerDoneTapped() {
        divisionsPickerView.resignFirstResponder()
        User.shared.divisionId = selectedDivisionIndexID
        academicDivisionTextField.text = divisionsList[User.shared.divisionId ?? 0]
        retrieveAcademicYear()
    }

    @objc
    private func academicYearPickerDoneTapped() {
        academicYearPickerView.resignFirstResponder()
        academicYearTextField.text = academicYears[selectedYearIndexID]
    }

    private func isMandatoryFieldsFilled() -> Bool {
        return !firstParentNumberTextField.isEmpty && !academicTypeTextField.isEmpty && !academicDivisionTextField.isEmpty &&
        !academicYearTextField.isEmpty && !schoolNameTextField.isEmpty
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
        User.shared.academicType = viewModel?.academicTypeIDs[selectedAcademicTypeIndexID]
        User.shared.academicTypeName = academicTypeTextField.text
        User.shared.divisionId = User.shared.divisionId ?? 0
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
