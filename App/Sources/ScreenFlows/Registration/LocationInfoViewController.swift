// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit

class LocationInfoViewController: UIViewController {
    // MARK: - IBOutlets

    @IBOutlet private var loadingIndicator: UIActivityIndicatorView! {
        didSet {
            loadingIndicator.hidesWhenStopped = true
        }
    }
    @IBOutlet private var wrongCredentialsImageView: UIImageView! {
        didSet {
            wrongCredentialsImageView.isHidden = true
        }
    }
    @IBOutlet private var wrongCredentialsImageViewHeight: NSLayoutConstraint! {
        didSet {
            wrongCredentialsImageViewHeight.constant = 0
        }
    }
    @IBOutlet private var countryTextField: NoCutPasteTextField! {
        didSet {
            countryTextField.addRightIcon(Images.path.image, width: 10, height: 6)
            countryTextField.inputView = countryPickerView
            countryTextField.isMandatoryTextField = true
        }
    }
    @IBOutlet private var cityTextField: NoCutPasteTextField! {
        didSet {
            cityTextField.addRightIcon(Images.path.image, width: 10, height: 6)
            cityTextField.inputView = cityPickerView
            cityTextField.isMandatoryTextField = true
        }
    }
    @IBOutlet private var districtTextField: NoCutPasteTextField! {
        didSet {
            districtTextField.isMandatoryTextField = true
        }
    }
    @IBOutlet private var addressTextField: UITextField!

    // MARK: - Private Properties

    private var viewModel: RegistrationViewModel?
    private var countries: [String] = []
    private var cities: [String] = []
    private var selectedCountry: String?
    private var selectedCountryIndex: Int?
    private var selectedCityIndex: Int?
    private var countryPickerView = PickerInputView<String>(height: 200)
    private var cityPickerView = PickerInputView<String>(height: 200)

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = RegistrationViewModel()
        retrieveCountriesList()
        configurePickerFields()
        configurePickerViews()
    }

    // MARK: - IBActions

    @IBAction private func didTapOnBack(_ sender: UIButton) {
        self.dismiss(animated: false)
    }

    // MARK: - Private Functions

    private func configurePickerViews() {
        countryPickerView.text = { $0 }
        cityPickerView.text = { $0 }

        countryTextField .keyboardToolbar.doneBarButton.setTarget(
            self,
            action: #selector(countriesPickerDoneTapped)
        )
        countryPickerView.didSelectAtIndex = { [unowned self] index in
            self.countryTextField.text = countries[index]
            self.selectedCountryIndex = index
            countryTextField.setNormalView()
        }

        cityTextField.keyboardToolbar.doneBarButton.setTarget(
            self,
            action: #selector(citiesPickerDoneTapped)
        )
        cityPickerView.didSelectAtIndex = { [unowned self] index in
            self.cityTextField.text = cities[index]
            self.selectedCityIndex = index
            cityTextField.setNormalView()
        }
    }

    private func configurePickerFields() {
        countryPickerView.items = { self.countries }
        cityPickerView.items = { self.cities }
    }

    private func retrieveCountriesList() {
        viewModel?.loadCountries { countries in
            self.countries = countries
        }
    }

    @objc
    private func countriesPickerDoneTapped() {
        let selectedIndex = selectedCountryIndex == nil ? 0 : selectedCountryIndex
        countryPickerView.resignFirstResponder()
        countryTextField.text = countries[selectedIndex ?? 0]
        self.selectedCountryIndex = selectedIndex
        self.selectedCountry = self.countryTextField.text
        loadingIndicator.startAnimating()
        viewModel?.loadCities(for: selectedCountryIndex ?? 0) { cities in
            self.loadingIndicator.stopAnimating()
            self.cities = cities
        }
    }

    @objc
    private func citiesPickerDoneTapped() {
        let selectedIndex = selectedCityIndex == nil ? 0 : selectedCityIndex
        cityPickerView.resignFirstResponder()
        cityTextField.text = cities[selectedIndex ?? 0]
        self.selectedCityIndex = selectedIndex
    }

    private func isMandatoryFieldsFilled() -> Bool {
        return !countryTextField.isEmpty && !cityTextField.isEmpty && !districtTextField.isEmpty
    }

    private func configureEmptyMandatoryFields() {
        if countryTextField.isEmpty {
            countryTextField.setErrorView()
        }
        if cityTextField.isEmpty {
            cityTextField.setErrorView()
        }
        if districtTextField.isEmpty {
            districtTextField.setErrorView()
        }
    }

    // MARK: - Segue

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        guard isMandatoryFieldsFilled() else {
            wrongCredentialsImageView.isHidden = false
            wrongCredentialsImageViewHeight.constant = 50.0
            configureEmptyMandatoryFields()
            return false
        }
        return true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        User.shared.country = viewModel?.countryCodes[selectedCityIndex ?? 0]
        User.shared.city = viewModel?.cityCodes[selectedCityIndex ?? 0]
        User.shared.region = districtTextField.text
        User.shared.address = addressTextField.text
    }
}
