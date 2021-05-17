// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit

class LocationInfoViewController: UIViewController {
    // MARK: - IBOutlets

    @IBOutlet private var countryTextField: NoCutPasteTextField! {
        didSet {
            countryTextField.addRightIcon(Images.path.image, width: 10, height: 6)
            countryTextField.inputView = countryPickerView
        }
    }
    @IBOutlet private var cityTextField: NoCutPasteTextField! {
        didSet {
            cityTextField.addRightIcon(Images.path.image, width: 10, height: 6)
            cityTextField.inputView = cityPickerView
        }
    }
    @IBOutlet private var districtTextField: UITextField!
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

    // MARK: - Private Functions

    private func configurePickerViews() {
        countryPickerView.text = { $0 }
        cityPickerView.text = { $0 }
        countryTextField .keyboardToolbar.doneBarButton.setTarget(
            self,
            action: #selector(pickerDoneTapped)
        )
        countryPickerView.didSelectAtIndex = { [unowned self] index in
            self.countryTextField.text = countries[index]
            self.selectedCountryIndex = index
        }
        cityPickerView.didSelectAtIndex = { [unowned self] index in
            self.cityTextField.text = cities[index]
            self.selectedCityIndex = index
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
    private func pickerDoneTapped() {
        countryPickerView.resignFirstResponder()
        self.selectedCountry = self.countryTextField.text
        viewModel?.loadCities(for: selectedCountryIndex ?? 0) { cities in
            self.cities = cities
        }
    }

    private func isMandatoryFieldsFilled() -> Bool {
        return !countryTextField.isEmpty && !cityTextField.isEmpty && !districtTextField.isEmpty
    }

    // MARK: - Segue

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        guard isMandatoryFieldsFilled() else {
            AlertHandler(presentingViewCtrl: self).showInformationAlert(title: "Error", message: "One of the fields is incorrect.")
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
