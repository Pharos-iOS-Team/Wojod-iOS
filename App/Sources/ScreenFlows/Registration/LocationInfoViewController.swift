// Copyright © 2021 Pharos Solutions. All rights reserved.

import SwiftyUserDefaults
import UIKit

class LocationInfoViewController: UIViewController {
    // MARK: - IBOutlets

    @IBOutlet private var loadingIndicator: UIActivityIndicatorView! {
        didSet {
            loadingIndicator.hidesWhenStopped = true
        }
    }
    @IBOutlet private var locationInfoTitleImageView: UIImageView! {
        didSet {
            locationInfoTitleImageView.image = Images.locationInfoTitle
        }
    }
    @IBOutlet private var secondMilestoneImageView: UIImageView! {
        didSet {
            secondMilestoneImageView.image = Images.secondMilestone
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
    @IBOutlet private var countryTextField: NoCutPasteTextField! {
        didSet {
            countryTextField.placeholder = L10n.Signup.LocationInfo.country
            countryTextField.addRightIcon(Images.path.image, width: 10, height: 6)
            countryTextField.inputView = countryPickerView
            countryTextField.isMandatoryTextField = true
            countryTextField.semanticContentAttribute = Language.semanticContent
            countryTextField.textAlignment = Language.textAlignment
        }
    }
    @IBOutlet private var cityTextField: NoCutPasteTextField! {
        didSet {
            cityTextField.placeholder = L10n.Signup.LocationInfo.city
            cityTextField.addRightIcon(Images.path.image, width: 10, height: 6)
            cityTextField.inputView = cityPickerView
            cityTextField.isMandatoryTextField = true
            cityTextField.semanticContentAttribute = Language.semanticContent
            cityTextField.textAlignment = Language.textAlignment
        }
    }
    @IBOutlet private var districtTextField: NoCutPasteTextField! {
        didSet {
            districtTextField.placeholder = L10n.Signup.LocationInfo.district
            districtTextField.semanticContentAttribute = Language.semanticContent
            districtTextField.textAlignment = Language.textAlignment
        }
    }
    @IBOutlet private var addressTextField: UITextField! {
        didSet {
            addressTextField.placeholder = L10n.Signup.LocationInfo.address
            addressTextField.semanticContentAttribute = Language.semanticContent
            addressTextField.textAlignment = Language.textAlignment
        }
    }
    @IBOutlet private var backButton: UIButton! {
        didSet {
            backButton.setImage(Images.localizedBackButton)
        }
    }
    @IBOutlet private var nextButton: SendButton!

    // MARK: - Private Properties

    private var viewModel: RegistrationViewModel?
    private var countries: [KeyName] = []
    private var cities: [KeyName] = []
    private var selectedCountry: String?
    private var selectedCountryIndex: Int?
    private var selectedCityIndex: Int?
    private var countryPickerView = PickerInputView<String>(height: 200)
    private var cityPickerView = PickerInputView<String>(height: 200)

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = RegistrationViewModel()
        configureSemanticAttribute()
        retrieveCountriesList()
        configurePickerFields()
        configurePickerViews()
        displayDataEnteredBeforePressingBackIfExists()
        configureTextFieldsDelegate()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideWrongCredentials()
    }

    // MARK: - IBActions

    @IBAction private func didTapOnBack(_ sender: UIButton) {
        retrieveDataEnteredFromUser()
        self.dismiss(animated: false)
    }

    @IBAction private func didTapOnNext(_ sender: Any) {
        if Environment.appName == .royalMedicine {
            performSegue(withIdentifier: "goToUniversity", sender: self)
        } else {
            performSegue(withIdentifier: "goToAcademicInfo", sender: self)
        }
    }
    // MARK: - Private Functions

    private func configurePickerViews() {
        countryPickerView.text = { $0 }
        cityPickerView.text = { $0 }

      countryTextField .iq.toolbar.doneBarButton.setTarget(
            self,
            action: #selector(countriesPickerDoneTapped)
        )
        countryPickerView.didSelectAtIndex = { [unowned self] index in
            self.countryTextField.text = countries[index].name
            self.selectedCountryIndex = index
            countryTextField.setNormalView()
        }

      cityTextField.iq.toolbar.doneBarButton.setTarget(
            self,
            action: #selector(citiesPickerDoneTapped)
        )
        cityPickerView.didSelectAtIndex = { [unowned self] index in
            self.cityTextField.text = cities.isEmpty ? "" : cities[index].name
            self.selectedCityIndex = index
            cityTextField.setNormalView()
        }
    }

    private func configurePickerFields() {
        countryPickerView.items = { self.countries.compactMap { $0.name } }
        cityPickerView.items = { self.cities.compactMap { $0.name } }
    }

    private func retrieveCountriesList() {
        viewModel?.loadCountries { countries in
            self.countries = countries ?? []
            self.selectEgyptAsDefaultCountry()
            self.retrieveCitiesList()
        }
    }

    private func retrieveCitiesList() {
        loadingIndicator.startAnimating()
        viewModel?.loadCities(for: User.shared.country ?? "EGY") { cities in
            self.loadingIndicator.stopAnimating()
            self.cities = cities ?? []
            self.configureAlexandriaAsDefaultCity()
        }
    }

    private func selectEgyptAsDefaultCountry() {
        guard User.shared.country == nil else { return }

        let defaultCountryIndex = countries.firstIndex { $0.key == "EGY" }
        let defaultCountry = countries.first { $0.key == "EGY" }
        User.shared.country = defaultCountry?.key
        User.shared.countryName = defaultCountry?.name
        countryTextField.text = defaultCountry?.name
        selectedCountryIndex = defaultCountryIndex
    }

    private func configureAlexandriaAsDefaultCity() {
        guard User.shared.city == nil else { return }

        let defaultCity = cities.first { $0.key == "ALX" }
        User.shared.city = defaultCity?.key
        User.shared.cityName = defaultCity?.name
        self.cityTextField.text = defaultCity?.name
    }

    @objc
    private func countriesPickerDoneTapped() {
        let selectedIndex = selectedCountryIndex == nil ? 0 : selectedCountryIndex
        countryPickerView.resignFirstResponder()
        countryTextField.text = countries[selectedIndex ?? 0].name
        selectedCountryIndex = selectedIndex
        self.selectedCountry = self.countryTextField.text
        loadingIndicator.startAnimating()
        viewModel?.loadCities(for: viewModel?.countryCodes[selectedCountryIndex ?? 0] ?? "") { cities in
            self.loadingIndicator.stopAnimating()
            self.cities = cities ?? []
            self.cityTextField.text = cities?.isEmpty ?? true ? "" : cities?[0].name
        }
    }

    @objc
    private func citiesPickerDoneTapped() {
        let selectedIndex = selectedCityIndex == nil ? 0 : selectedCityIndex
        cityPickerView.resignFirstResponder()
        cityTextField.text = cities.isEmpty ? "" : cities[selectedIndex ?? 0].name
        selectedCityIndex = selectedIndex
    }

    private func isMandatoryFieldsFilled() -> Bool {
        if cities.isEmpty {
            return !countryTextField.isEmpty
        } else {
            return !countryTextField.isEmpty && !cityTextField.isEmpty
        }
    }

    private func configureEmptyMandatoryFields() {
        if countryTextField.isEmpty {
            countryTextField.setErrorView()
        }
        if cityTextField.isEmpty {
            cityTextField.setErrorView()
        }
    }

    private func retrieveDataEnteredFromUser() {
        User.shared.country = countryTextField.isEmpty ? nil : countries[selectedCountryIndex ?? 0].key
        User.shared.countryName = countryTextField.isEmpty ? nil : countries[selectedCountryIndex ?? 0].name
        User.shared.city = cityTextField.isEmpty ? nil : cities[selectedCityIndex ?? 0].key
        User.shared.cityName = cityTextField.isEmpty ? nil : cities[selectedCityIndex ?? 0].name
        User.shared.region = districtTextField.text
        User.shared.address = addressTextField.text
    }

    private func displayDataEnteredBeforePressingBackIfExists() {
        countryTextField.text = User.shared.countryName
        cityTextField.text = User.shared.cityName
        districtTextField.text = User.shared.region
        addressTextField.text = User.shared.address
    }

    private func displayWrongCredentials() {
        wrongCredentialsImageView.isHidden = false
        wrongCredentialsImageViewHeight.constant = 50.0
    }

    private func hideWrongCredentials() {
        wrongCredentialsImageView.isHidden = true
        wrongCredentialsImageViewHeight.constant = 0
    }

    private func configureTextFieldsDelegate() {
        countryTextField.delegate = self
        cityTextField.delegate = self
        districtTextField.delegate = self
    }

    // MARK: - Segue

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        guard isMandatoryFieldsFilled() else {
            displayWrongCredentials()
            configureEmptyMandatoryFields()
            return false
        }
        return true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        retrieveDataEnteredFromUser()
    }
}

// MARK: - Text Field Delegate

extension LocationInfoViewController: UITextFieldDelegate {
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
