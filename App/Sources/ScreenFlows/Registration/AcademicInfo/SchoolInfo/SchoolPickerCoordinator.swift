// Copyright © 2026 Pharos Solutions. All rights reserved.

import IQKeyboardManagerSwift
import UIKit

final class SchoolPickerCoordinator: NSObject {
    struct TextFields {
        weak var academicType: NoCutPasteTextField?
        weak var academicDivision: NoCutPasteTextField?
        weak var academicYear: NoCutPasteTextField?
        weak var field: NoCutPasteTextField?
    }

    private weak var viewModel: AcademicInfoViewModel?
    private weak var schoolVC: SchoolInfoViewController?

    private let academicTypesPicker: PickerInputView<String>
    private let divisionsPicker: PickerInputView<String>
    private let academicYearPicker: PickerInputView<String>
    private let fieldsPicker: PickerInputView<String>

    private var textFields = TextFields()

    init(
        viewModel: AcademicInfoViewModel,
        schoolVC: SchoolInfoViewController,
        academicTypesPicker: PickerInputView<String>,
        divisionsPicker: PickerInputView<String>,
        academicYearPicker: PickerInputView<String>,
        fieldsPicker: PickerInputView<String>
    ) {
        self.viewModel = viewModel
        self.schoolVC = schoolVC
        self.academicTypesPicker = academicTypesPicker
        self.divisionsPicker = divisionsPicker
        self.academicYearPicker = academicYearPicker
        self.fieldsPicker = fieldsPicker
    }

    @MainActor
    func configure(with textFields: TextFields) {
        self.textFields = textFields
        setupPickerItemsClosures()
        setupInlineSelectionCallbacks()
        setupToolbarDoneTargets()
    }

    private func setupPickerItemsClosures() {
        [academicTypesPicker, divisionsPicker, academicYearPicker, fieldsPicker].forEach { $0.text = { $0 } }
        academicTypesPicker.items = { [weak self] in self?.viewModel?.pickerItems(for: .academicTypes) ?? [] }
        divisionsPicker.items = { [weak self] in self?.viewModel?.pickerItems(for: .divisions) ?? [] }
        academicYearPicker.items = { [weak self] in self?.viewModel?.pickerItems(for: .academicYears) ?? [] }
        fieldsPicker.items = { [weak self] in self?.viewModel?.pickerItems(for: .schoolFields) ?? [] }
    }

    private func setupInlineSelectionCallbacks() {
        academicTypesPicker.didSelectAtIndex = { [weak self] index in
            guard let viewModel = self?.viewModel else { return }
            viewModel.selectedAcademicType = viewModel.academicTypesList?[safe: index]
            self?.textFields.academicType?.text = viewModel.selectedAcademicType?.value
            self?.textFields.academicType?.setNormalView()
        }
        divisionsPicker.didSelectAtIndex = { [weak self] index in
            guard let viewModel = self?.viewModel else { return }
            viewModel.selectedDivision = viewModel.divisionsList[safe: index]
            self?.textFields.academicDivision?.text = viewModel.selectedDivision?.value
            self?.textFields.academicDivision?.setNormalView()
        }
        academicYearPicker.didSelectAtIndex = { [weak self] index in
            guard let self, let viewModel = viewModel, !viewModel.academicYears.isEmpty else { return }
            viewModel.selectedYearIndex = index
            textFields.academicYear?.text = viewModel.academicYears[safe: index]?.value
            textFields.academicYear?.setNormalView()
            viewModel.onFormDidChange?()
        }
        fieldsPicker.didSelectAtIndex = { [weak self] index in
            guard let viewModel = self?.viewModel else { return }
            viewModel.selectedSchoolField = viewModel.schoolFields[safe: index]
            self?.textFields.field?.text = viewModel.selectedSchoolField?.value
            self?.textFields.field?.setNormalView()
        }
    }

    @MainActor
    private func setupToolbarDoneTargets() {
        textFields.academicType?.iq.toolbar.titleBarButton.title = L10n.Signup.School.academicType.replacingOccurrences(of: "*", with: "")
        textFields.academicType?.iq.toolbar.doneBarButton.setTarget(self, action: #selector(academicTypePickerDoneTapped))

        textFields.academicDivision?.iq.toolbar.titleBarButton.title = L10n.Signup.School.academicDivision.replacingOccurrences(of: "*", with: "")
        textFields.academicDivision?.iq.toolbar.doneBarButton.setTarget(self, action: #selector(academicDivisionPickerDoneTapped))

        textFields.academicYear?.iq.toolbar.titleBarButton.title = L10n.Signup.School.academicYear.replacingOccurrences(of: "*", with: "")
        textFields.academicYear?.iq.toolbar.doneBarButton.setTarget(self, action: #selector(academicYearPickerDoneTapped))

        textFields.field?.iq.toolbar.titleBarButton.title = L10n.Signup.School.field
        textFields.field?.iq.toolbar.doneBarButton.setTarget(self, action: #selector(schoolFieldPickerDoneTapped))
    }

    @objc
    private func academicTypePickerDoneTapped() {
        guard let viewModel = viewModel else { return }
        if viewModel.selectedAcademicType == nil { viewModel.selectedAcademicType = viewModel.academicTypesList?[safe: 0] }
        academicTypesPicker.resignFirstResponder()
        textFields.academicType?.text = viewModel.selectedAcademicType?.value
        schoolVC?.retrieveAcademicDivisions()
    }

    @objc
    private func academicDivisionPickerDoneTapped() {
        guard let viewModel = viewModel else { return }
        if viewModel.selectedDivision == nil { viewModel.selectedDivision = viewModel.divisionsList[safe: 0] }
        divisionsPicker.resignFirstResponder()
        textFields.academicDivision?.text = viewModel.selectedDivision?.value
        schoolVC?.retrieveAcademicYear()
        schoolVC?.retrieveSchoolFields()
    }

    @objc
    private func academicYearPickerDoneTapped() {
        guard let viewModel = viewModel, !viewModel.academicYears.isEmpty else { return }
        academicYearPicker.resignFirstResponder()
        textFields.academicYear?.text = viewModel.academicYears[safe: viewModel.selectedYearIndex]?.value
        viewModel.onFormDidChange?()
    }

    @objc
    private func schoolFieldPickerDoneTapped() {
        guard let viewModel = viewModel else { return }
        if viewModel.selectedSchoolField == nil { viewModel.selectedSchoolField = viewModel.schoolFields[safe: 0] }
        fieldsPicker.resignFirstResponder()
        textFields.field?.text = viewModel.selectedSchoolField?.value
    }
}
