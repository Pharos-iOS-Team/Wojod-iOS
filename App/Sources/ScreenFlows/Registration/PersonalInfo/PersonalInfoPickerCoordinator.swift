// Copyright © 2026 Pharos Solutions. All rights reserved.

import IQKeyboardManagerSwift
import UIKit

// MARK: - Delegate

protocol PersonalInfoPickerCoordinatorDelegate: AnyObject {
    func pickerCoordinatorNeedsButtonUpdate()
    func pickerCoordinatorCountryConfirmed()
}

// MARK: - PersonalInfoPickerCoordinator

final class PersonalInfoPickerCoordinator: NSObject {
    private weak var viewModel: PersonalInfoViewModel?
    weak var delegate: PersonalInfoPickerCoordinatorDelegate?

    private let countryPickerView: PickerInputView<String>
    private let cityPickerView: PickerInputView<String>
    private weak var countryTextField: NoCutPasteTextField?
    private weak var cityTextField: NoCutPasteTextField?

    init(
        viewModel: PersonalInfoViewModel,
        countryPickerView: PickerInputView<String>,
        cityPickerView: PickerInputView<String>
    ) {
        self.viewModel = viewModel
        self.countryPickerView = countryPickerView
        self.cityPickerView = cityPickerView
    }

    @MainActor
    func configure(countryTextField: NoCutPasteTextField, cityTextField: NoCutPasteTextField) {
        self.countryTextField = countryTextField
        self.cityTextField = cityTextField

        countryPickerView.text = { $0 }
        cityPickerView.text = { $0 }

        countryPickerView.items = { [weak self] in
            self?.viewModel?.countries.compactMap { $0.name } ?? []
        }
        cityPickerView.items = { [weak self] in
            self?.viewModel?.cities.compactMap { $0.name } ?? []
        }

        countryPickerView.didSelectAtIndex = { [weak self] index in
            guard let self, let viewModel = self.viewModel else { return }
            viewModel.selectCountry(at: index)
            countryTextField.text = viewModel.countries[safe: index]?.name ?? ""
            countryTextField.setNormalView()
        }

        cityPickerView.didSelectAtIndex = { [weak self] index in
            guard let self, let viewModel = self.viewModel else { return }
            viewModel.selectCity(at: index)
            cityTextField.text = viewModel.cities.isEmpty ? "" : viewModel.cities[safe: index]?.name ?? ""
            cityTextField.setNormalView()
            self.delegate?.pickerCoordinatorNeedsButtonUpdate()
        }

        countryTextField.iq.toolbar.titleBarButton.title = PersonalInfoField.country.placeholder
        countryTextField.iq.toolbar.doneBarButton.setTarget(self, action: #selector(countryPickerDoneTapped))
        cityTextField.iq.toolbar.titleBarButton.title = PersonalInfoField.city.placeholder
        cityTextField.iq.toolbar.doneBarButton.setTarget(self, action: #selector(cityPickerDoneTapped))
    }

    @objc
    private func countryPickerDoneTapped() {
        guard let viewModel = viewModel else { return }
        let idx = viewModel.selectedCountryIndex ?? 0
        viewModel.selectCountry(at: idx)
        countryPickerView.resignFirstResponder()
        countryTextField?.text = viewModel.countries[safe: idx]?.name ?? ""
        cityTextField?.text = ""
        delegate?.pickerCoordinatorCountryConfirmed()
    }

    @objc
    private func cityPickerDoneTapped() {
        guard let viewModel = viewModel else { return }
        let idx = viewModel.selectedCityIndex ?? 0
        viewModel.selectCity(at: idx)
        cityPickerView.resignFirstResponder()
        cityTextField?.text = viewModel.cities.isEmpty ? "" : viewModel.cities[safe: idx]?.name ?? ""
        delegate?.pickerCoordinatorNeedsButtonUpdate()
    }
}
