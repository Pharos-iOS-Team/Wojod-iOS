// Copyright © 2026 Pharos Solutions. All rights reserved.

import IQKeyboardManagerSwift
import UIKit

extension PersonalInfoViewController {
    func field(for key: PersonalInfoField) -> NoCutPasteTextField? {
        inputFields.first { $0.tag == key.rawValue }
    }

    func configureFields() {
        PersonalInfoField.allCases.forEach { key in
            guard let field = field(for: key) else { return }
            switch key.configStyle {
            case .mandatory:
                RegistrationFieldConfigurer.configureMandatory(field, placeholder: key.placeholder)
            case .optional:
                RegistrationFieldConfigurer.configureOptional(field, placeholder: key.placeholder)
            case .picker:
                let picker = key == .country ? countryPickerView : cityPickerView
                RegistrationFieldConfigurer.configurePickerField(field, placeholder: key.placeholder, picker: picker)
            }
        }
    }

    func configureTextFields() {
        inputFields.forEach { $0.delegate = self }
        let skipLiveTags = Set([PersonalInfoField.country, .city, .district, .homeNumber, .address].map { $0.rawValue })
        inputFields
            .filter { !skipLiveTags.contains($0.tag) }
            .forEach { $0.addTarget(self, action: #selector(liveValidateField(_:)), for: .editingChanged) }
        field(for: .district)?.addTarget(self, action: #selector(districtTextChanged), for: .editingChanged)
    }

    func configurePickerCoordinator() {
        guard let countryField = field(for: .country), let cityField = field(for: .city) else { return }
        pickerCoordinator = PersonalInfoPickerCoordinator(
            viewModel: viewModel,
            countryPickerView: countryPickerView,
            cityPickerView: cityPickerView
        )
        pickerCoordinator?.delegate = self
        pickerCoordinator?.configure(countryTextField: countryField, cityTextField: cityField)
        configureFieldIndicators()
    }

    func configureFieldIndicators() {
        [countryFieldIndicator, cityFieldIndicator].forEach {
            $0.hidesWhenStopped = true
            $0.isUserInteractionEnabled = false
        }
        field(for: .country)?.rightView = makeRightViewContainer(with: countryFieldIndicator)
        field(for: .country)?.rightViewMode = .always
        field(for: .city)?.rightView = makeRightViewContainer(with: cityFieldIndicator)
        field(for: .city)?.rightViewMode = .always

        nextButtonIndicator.hidesWhenStopped = true
        nextButtonIndicator.isUserInteractionEnabled = false
        nextButtonIndicator.color = .white
        nextButton.addSubview(nextButtonIndicator)
        nextButtonIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nextButtonIndicator.centerXAnchor.constraint(equalTo: nextButton.centerXAnchor),
            nextButtonIndicator.centerYAnchor.constraint(equalTo: nextButton.centerYAnchor)
        ])
    }

    func makeRightViewContainer(with indicator: UIActivityIndicatorView) -> UIView {
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 20))
        let arrowImageView = UIImageView(image: Images.path.image)
        arrowImageView.frame = CGRect(x: 10, y: 7, width: 10, height: 6)
        arrowImageView.contentMode = .scaleAspectFit
        containerView.addSubview(arrowImageView)
        indicator.frame = CGRect(x: 5, y: 0, width: 20, height: 20)
        containerView.addSubview(indicator)
        return containerView
    }

    func startNextButtonLoading() {
        nextButton.isEnabled = false
        nextButtonIndicator.startAnimating()
        nextButton.setImage(nil, for: .normal)
        nextButton.setTitle(nil, for: .normal)
    }

    func stopNextButtonLoading() {
        nextButtonIndicator.stopAnimating()
        nextButton.setImage(Images.localizedDisclosureIndicatorButton, for: .normal)
        updateNextButtonState()
    }

    @objc
    func districtTextChanged() {
        guard let districtField = field(for: .district) else { return }
        districtField.isEmpty ? districtField.setErrorView() : districtField.setNormalView()
        updateNextButtonState()
    }

    @objc
    private func liveValidateField(_ sender: UITextField) {
        updateNextButtonState()
        errorDisplay.clearError(for: sender)
        guard !(sender.tag == PersonalInfoField.mobileNumber2.rawValue && (sender.text ?? "").isEmpty) else { return }
        saveStateToStore()
        let fieldKey: PersonalInfoField? = .init(rawValue: sender.tag)
        if let fieldKey, let error = viewModel.validateField(fieldKey) {
            sender.setBorder(color: .red, width: 1, cornerRadius: 6)
            errorDisplay.showError(for: sender, message: error.localizedMessage)
        }
    }

    func retrieveCountriesList() {
        countryFieldIndicator.startAnimating()
        Task { [weak self] in
            guard let self = self else { return }
            let countries = await self.viewModel.loadCountries()
            await MainActor.run {
                self.countryFieldIndicator.stopAnimating()
                if let idx = self.viewModel.selectDefaultCountry() {
                    self.field(for: .country)?.text = countries[safe: idx]?.name ?? ""
                }
                self.retrieveCitiesList()
            }
        }
    }

    func retrieveCitiesList() {
        guard let selectedIndex = viewModel.selectedCountryIndex else { return }
        cityFieldIndicator.startAnimating()
        Task { [weak self] in
            guard let self = self else { return }
            let cities = await self.viewModel.loadCities(forCountryAt: selectedIndex)
            await MainActor.run {
                self.cityFieldIndicator.stopAnimating()
                if cities.isEmpty {
                    self.field(for: .city)?.text = ""
                } else {
                    let idx = self.viewModel.selectRestoredCity(from: cities)
                    self.field(for: .city)?.text = cities[safe: idx]?.name ?? ""
                }
                self.updateNextButtonState()
            }
        }
    }

    func currentFieldValues() -> PersonalInfoFieldValues {
        PersonalInfoFieldValues(
            name: field(for: .name)?.text ?? "",
            mobileNumber: field(for: .mobileNumber)?.text ?? "",
            mobileNumber2: field(for: .mobileNumber2)?.text ?? "",
            homeNumber: field(for: .homeNumber)?.text ?? "",
            email: field(for: .email)?.text ?? "",
            password: field(for: .password)?.text ?? "",
            confirmPassword: field(for: .confirmPassword)?.text ?? "",
            countryName: field(for: .country)?.text ?? "",
            cityName: field(for: .city)?.text ?? "",
            district: field(for: .district)?.text ?? "",
            address: field(for: .address)?.text ?? ""
        )
    }

    func saveStateToStore() {
        viewModel.saveStateToStore(values: currentFieldValues())
    }

    func restoreStateFromStore() {
        let values = viewModel.restoreStateFromStore()
        field(for: .name)?.text = values.name
        field(for: .mobileNumber)?.text = values.mobileNumber
        field(for: .mobileNumber2)?.text = values.mobileNumber2
        field(for: .homeNumber)?.text = values.homeNumber
        field(for: .email)?.text = values.email
        field(for: .password)?.text = values.password
        field(for: .confirmPassword)?.text = values.confirmPassword
        field(for: .district)?.text = values.district
        field(for: .address)?.text = values.address
    }

    func updateNextButtonState() {
        let enabled = viewModel.isMandatoryFieldsFilled(values: currentFieldValues())
        nextButton.isEnabled = enabled
        nextButton.backgroundColor = enabled ? Colors.sendButtonColor.color : Colors.darkGreyColor.color
    }

    func displayWrongCredentials() {
        wrongCredentialsImageView.isHidden = false
        hintContentView.isHidden = true
        mobileNumberHintLabel.isHidden = true
    }

    func hideWrongCredentials() {
        wrongCredentialsImageView.isHidden = true
        hintContentView.isHidden = false
        mobileNumberHintLabel.isHidden = false
    }

    func showValidationErrors(_ errors: [RegistrationValidationError]) {
        errorDisplay.clearAll()
        for error in errors {
            guard let field = viewModel.validationFieldMap[error].flatMap({ field(for: $0) }) else { continue }
            field.setErrorView()
            errorDisplay.showError(for: field, message: error.localizedMessage)
        }
    }
}
