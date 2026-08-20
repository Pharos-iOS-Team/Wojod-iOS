// Copyright © 2026 Pharos Solutions. All rights reserved.

import IQKeyboardManagerSwift
import PhoneNumberKit
import PhoneNumberKitUI
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
            case .phone:
                RegistrationFieldConfigurer.configureMandatory(field, placeholder: key.placeholder)
                let phoneTextField = makePhoneTextField(placeholder: key.placeholder)
                embedPhoneTextField(phoneTextField, over: field, key: key)
                primaryPhoneTextField = phoneTextField
            }
        }
    }

    // MARK: - Phone TextField Factory

    private func makePhoneTextField(placeholder: String) -> PhoneNumberTextField {
        return PhoneNumberTextField().with {
            $0.withFlag = true
            $0.withDefaultPickerUI = true
            $0.withPrefix = true
            $0.withExamplePlaceholder = true
            let code = User.shared.countryCode ?? PhoneNumberValidator.egyptCountryCode
            let digits = code.hasPrefix("+") ? String(code.dropFirst()) : code
            $0.defaultRegion = UInt64(digits).flatMap { PhoneNumberUtility().mainCountry(forCode: $0) }
                ?? PhoneNumberValidator.egyptRegionCode

            $0.semanticContentAttribute = .forceLeftToRight
            $0.textAlignment = .left
            $0.translatesAutoresizingMaskIntoConstraints = false

            $0.borderStyle = .none
            $0.backgroundColor = .white
            $0.font = .systemFont(ofSize: 14)
            $0.layer.masksToBounds = true
            $0.setBorder(color: Asset.Colors.backgroundLightGreyColor.color, width: 1, cornerRadius: 5)
            $0.flagButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 6)
            $0.delegate = self
        }
    }

    private func embedPhoneTextField(_ phoneTextField: PhoneNumberTextField, over storyboardField: UITextField, key: PersonalInfoField) {
        guard let superview = storyboardField.superview else { return }
        superview.addSubview(phoneTextField)
        NSLayoutConstraint.activate([
            phoneTextField.topAnchor.constraint(equalTo: storyboardField.topAnchor),
            phoneTextField.leadingAnchor.constraint(equalTo: storyboardField.leadingAnchor),
            phoneTextField.trailingAnchor.constraint(equalTo: storyboardField.trailingAnchor),
            phoneTextField.heightAnchor.constraint(equalTo: storyboardField.heightAnchor)
        ])
        storyboardField.isHidden = true
        phoneTextField.addTarget(self, action: #selector(primaryPhoneDidChange), for: .editingChanged)
    }

    @objc
    private func primaryPhoneDidChange() {
        guard let textField = primaryPhoneTextField else { return }
        phoneTextFieldDidChange(for: .mobileNumber, phoneTextField: textField)
    }

    private func phoneTextFieldDidChange(for key: PersonalInfoField, phoneTextField: PhoneNumberTextField) {
        saveStateToStore()
        updateNextButtonState()
        let sourceField: NoCutPasteTextField?
        switch key {
        case .mobileNumber:
            sourceField = field(for: .mobileNumber)
        case .mobileNumber2:
            sourceField = field(for: .mobileNumber2)
        default:
            sourceField = nil
        }
        guard let textField = sourceField else { return }
        errorDisplay.clearError(for: textField)
        guard !(key == .mobileNumber2 && phoneTextField.nationalNumber.isEmpty) else { return }
        if let error = viewModel.validateField(key) {
            textField.setBorder(color: .red, width: 1, cornerRadius: 6)
            errorDisplay.showError(for: textField, message: error.localizedMessage)
        }
    }

    // MARK: - Text Field Configuration

    func configureTextFields() {
        inputFields.forEach { $0.delegate = self }
        let skipLiveTags = Set([
            PersonalInfoField.country, .city, .district, .homeNumber, .address,
            .mobileNumber
        ].map { $0.rawValue })
        inputFields
            .filter { !skipLiveTags.contains($0.tag) }
            .forEach { $0.addTarget(self, action: #selector(liveValidateField(_:)), for: .editingChanged) }
        field(for: .district)?.addTarget(self, action: #selector(districtTextChanged), for: .editingChanged)
    }

    // MARK: - Picker Coordinator

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

    // MARK: - Loading

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

    // MARK: - Field Targets

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

    // MARK: - Country / City Loading

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

    // MARK: - State

    private func dialCodeForRegion(_ region: String) -> String {
        let code = PhoneNumberUtility().countryCode(for: region) ?? 20
        return "+\(code)"
    }

    func currentFieldValues() -> PersonalInfoFieldValues {
        let primaryRegion = primaryPhoneTextField?.currentRegion ?? PhoneNumberValidator.egyptRegionCode
        return PersonalInfoFieldValues(
            name: field(for: .name)?.text ?? "",
            mobileNumber: primaryPhoneTextField?.nationalNumber ?? field(for: .mobileNumber)?.text ?? "",
            mobileCountryCode: dialCodeForRegion(primaryRegion),
            mobileRegionCode: primaryRegion,
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
        if !values.mobileNumber.isEmpty {
            primaryPhoneTextField?.text = dialCodeForRegion(values.mobileRegionCode) + values.mobileNumber
        }
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
