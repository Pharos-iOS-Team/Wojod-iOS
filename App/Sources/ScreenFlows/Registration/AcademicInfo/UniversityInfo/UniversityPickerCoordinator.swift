// Copyright © 2026 Pharos Solutions. All rights reserved.

import IQKeyboardManagerSwift
import UIKit

final class UniversityPickerCoordinator: NSObject {
    struct TextFields {
        weak var university: NoCutPasteTextField?
        weak var uniField: NoCutPasteTextField?
        weak var uniYear: NoCutPasteTextField?
    }

    private weak var viewModel: AcademicInfoViewModel?
    private weak var universityVC: UniversityInfoViewController?

    private let universityPicker: PickerInputView<String>
    private let uniFieldPicker: PickerInputView<String>
    private let uniYearPicker: PickerInputView<String>

    private var textFields = TextFields()

    init(
        viewModel: AcademicInfoViewModel,
        universityVC: UniversityInfoViewController,
        universityPicker: PickerInputView<String>,
        uniFieldPicker: PickerInputView<String>,
        uniYearPicker: PickerInputView<String>
    ) {
        self.viewModel = viewModel
        self.universityVC = universityVC
        self.universityPicker = universityPicker
        self.uniFieldPicker = uniFieldPicker
        self.uniYearPicker = uniYearPicker
    }

    @MainActor
    func configure(with textFields: TextFields) {
        self.textFields = textFields
        setupPickerItemsClosures()
        setupInlineSelectionCallbacks()
        setupToolbarDoneTargets()
    }

    private func setupPickerItemsClosures() {
        [universityPicker, uniFieldPicker, uniYearPicker].forEach { $0.text = { $0 } }
        universityPicker.items = { [weak self] in self?.viewModel?.pickerItems(for: .universities) ?? [] }
        uniFieldPicker.items = { [weak self] in self?.viewModel?.pickerItems(for: .uniFields) ?? [] }
        uniYearPicker.items = { [weak self] in self?.viewModel?.pickerItems(for: .uniYears) ?? [] }
    }

    private func setupInlineSelectionCallbacks() {
        universityPicker.didSelectAtIndex = { [weak self] index in
            guard let viewModel = self?.viewModel else { return }
            viewModel.selectedUniIndex = index
            self?.textFields.university?.text = viewModel.universities[safe: index]?.value
            self?.textFields.university?.setNormalView()
        }
        uniFieldPicker.didSelectAtIndex = { [weak self] index in
            guard let viewModel = self?.viewModel else { return }
            viewModel.selectedUniFieldIndex = index
            self?.textFields.uniField?.text = viewModel.uniFields[safe: index]?.value
            self?.textFields.uniField?.setNormalView()
            viewModel.onFormDidChange?()
        }
        uniYearPicker.didSelectAtIndex = { [weak self] index in
            guard let self, let viewModel = viewModel, !viewModel.uniYears.isEmpty else { return }
            viewModel.selectedUniYearIndex = index
            textFields.uniYear?.text = viewModel.uniYears[safe: index]?.value
            textFields.uniYear?.setNormalView()
            viewModel.onFormDidChange?()
        }
    }

    @MainActor
    private func setupToolbarDoneTargets() {
        textFields.university?.iq.toolbar.titleBarButton.title = L10n.Signup.UniversityScreen.university.replacingOccurrences(of: "*", with: "")
        textFields.university?.iq.toolbar.doneBarButton.setTarget(self, action: #selector(universityPickerDoneTapped))

        textFields.uniField?.iq.toolbar.titleBarButton.title = L10n.Signup.UniversityScreen.field.replacingOccurrences(of: "*", with: "")
        textFields.uniField?.iq.toolbar.doneBarButton.setTarget(self, action: #selector(uniFieldPickerDoneTapped))

        textFields.uniYear?.iq.toolbar.titleBarButton.title = L10n.Signup.UniversityScreen.year.replacingOccurrences(of: "*", with: "")
        textFields.uniYear?.iq.toolbar.doneBarButton.setTarget(self, action: #selector(uniYearPickerDoneTapped))
    }

    @objc
    private func universityPickerDoneTapped() {
        guard let viewModel = viewModel else { return }
        universityPicker.resignFirstResponder()
        textFields.university?.text = viewModel.universities[safe: viewModel.selectedUniIndex]?.value
        universityVC?.retrieveUniFieldsAndYears()
    }

    @objc
    private func uniFieldPickerDoneTapped() {
        guard let viewModel = viewModel else { return }
        uniFieldPicker.resignFirstResponder()
        textFields.uniField?.text = viewModel.uniFields.isEmpty ? "" : viewModel.uniFields[safe: viewModel.selectedUniFieldIndex]?.value
        viewModel.onFormDidChange?()
    }

    @objc
    private func uniYearPickerDoneTapped() {
        guard let viewModel = viewModel, !viewModel.uniYears.isEmpty else { return }
        uniYearPicker.resignFirstResponder()
        textFields.uniYear?.text = viewModel.uniYears[safe: viewModel.selectedUniYearIndex]?.value
        viewModel.onFormDidChange?()
    }
}
