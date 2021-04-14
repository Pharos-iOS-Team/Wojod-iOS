// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit

class SchoolViewController: UIViewController {
    // MARK: - IBOutlets

    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var contentView: UIView!
    @IBOutlet private var firstParentNumberTextField: UITextField!
    @IBOutlet private var secondParentNumberTextField: UITextField!
    @IBOutlet private var schoolNameTextField: UITextField!
    @IBOutlet private var academicTypeTextField: NoCutPasteTextField! {
        didSet {
            academicTypeTextField.addRightIcon(Images.path.image, width: 10, height: 6)
            academicTypeTextField.inputView = academicTypesPickerView
        }
    }
    @IBOutlet private var academicDivisionTextField: NoCutPasteTextField! {
        didSet {
            academicDivisionTextField.addRightIcon(Images.path.image, width: 10, height: 6)
            academicDivisionTextField.inputView = divisionsPickerView
        }
    }
    @IBOutlet private var academicYearTextField: NoCutPasteTextField! {
        didSet {
            academicYearTextField.addRightIcon(Images.path.image, width: 10, height: 6)
            academicYearTextField.inputView = academicYearPickerView
        }
    }

    // MARK: - Private Properties

    private var viewModel: RegistrationViewModel?
    private var selectedAcademicTypeIndexID: Int?
    private var selectedDivisionIndexID: Int?
    private var selectedYearIndexID: Int?
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
        loadAcademicTypes()
        retrieveAcademicDivisions()
        configurePickerFields()
        configurePickerViews()
    }

    // MARK: - Private Functions

    private func configurePickerFields() {
        divisionsPickerView.items = { self.divisionsList }
        academicTypesPickerView.items = { self.academicTypesList }
        academicYearPickerView.items = { self.academicYears }

        academicDivisionTextField.keyboardToolbar.doneBarButton.setTarget(self, action: #selector(pickerDoneTapped))
    }

    private func configurePickerViews() {
        divisionsPickerView.text = { $0 }
        academicTypesPickerView.text = { $0 }
        academicYearPickerView.text = { $0 }

        divisionsPickerView.didSelectAtIndex = { [unowned self] index in
            academicDivisionTextField.text = self.divisionsList[index]
            self.selectedDivisionIndexID = index
        }
        academicTypesPickerView.didSelectAtIndex = { [unowned self] index in
            academicTypeTextField.text = self.academicTypesList[index]
            self.selectedAcademicTypeIndexID = index
        }
        academicYearPickerView.didSelectAtIndex = { [unowned self] index in
            academicYearTextField.text = self.academicYears[index]
            self.selectedYearIndexID = index
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
        viewModel?.loadBatches(for: selectedDivisionIndexID ?? 0) { batches in
            self.academicYears = batches
        }
    }

    @objc
    private func pickerDoneTapped() {
        divisionsPickerView.resignFirstResponder()
        retrieveAcademicYear()
    }

    private func isMandatoryFieldsFilled() -> Bool {
        return !firstParentNumberTextField.isEmpty && !academicTypeTextField.isEmpty && !academicDivisionTextField.isEmpty &&
        !academicYearTextField.isEmpty && !schoolNameTextField.isEmpty
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
        User.shared.educationLevel = 0
        User.shared.parentNumber = firstParentNumberTextField.text
        User.shared.parentNumber2 = secondParentNumberTextField.text
        User.shared.academicType = viewModel?.academicTypeIDs[selectedAcademicTypeIndexID ?? 0]
        User.shared.divisionId = viewModel?.divisionIDs[selectedDivisionIndexID ?? 0]
        User.shared.divisionName = academicDivisionTextField.text
        User.shared.batch = viewModel?.batchesIDs[selectedYearIndexID ?? 0]
        User.shared.batchName = academicYearTextField.text
        User.shared.schoolName = schoolNameTextField.text
    }
}
