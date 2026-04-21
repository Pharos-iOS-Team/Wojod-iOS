// Copyright © 2026 Pharos Solutions. All rights reserved.

import Dependencies
import Foundation

struct PersonalInfoFieldValues {
    var name: String
    var mobileNumber: String
    var mobileNumber2: String
    var homeNumber: String
    var email: String
    var password: String
    var confirmPassword: String
    var countryName: String
    var cityName: String
    var district: String
    var address: String
}

final class PersonalInfoViewModel {
    @Dependency(\.apiProvider)
    private var apiProvider: ApiProvider

    private(set) var countries: [KeyName] = []
    private(set) var cities: [KeyName] = []
    private(set) var selectedCountryIndex: Int?
    private(set) var selectedCityIndex: Int?
    var hasCities: Bool { !cities.isEmpty }
    let validationFieldMap: [RegistrationValidationError: PersonalInfoField] = [
        .nameEmpty: .name,
        .phoneInvalid: .mobileNumber,
        .phone2Invalid: .mobileNumber2,
        .phone2SameAsPhone1: .mobileNumber2,
        .emailInvalid: .email,
        .passwordTooShort: .password,
        .passwordMismatch: .confirmPassword,
        .countryMissing: .country,
        .cityMissing: .city,
        .regionEmpty: .district
    ]

    init() {}

    // MARK: - Intent Methods

    func selectCountry(at index: Int) {
        selectedCountryIndex = index
        cities = []
        selectedCityIndex = nil
    }

    func selectCity(at index: Int) {
        selectedCityIndex = index
    }

    func loadCountries() async -> [KeyName] {
        let result = (try? await apiProvider.request(.registration(.countries), decodeTo: ApiResponse<[KeyName]>.self).data) ?? []
        countries = result
        return result
    }

    func loadCities(forCountryAt index: Int) async -> [KeyName] {
        guard let countryCode = countries[safe: index]?.key else { return [] }
        let requestModel = CitiesRequestModel(selectedCountry: countryCode)
        let result = (try? await apiProvider.request(.registration(.cities(requestModel)), decodeTo: ApiResponse<[KeyName]>.self).data) ?? []
        cities = result
        RegistrationStore.shared.update { state in state.hasCities = !result.isEmpty }
        return result
    }

    func selectDefaultCountry() -> Int? {
        let storeCountry = RegistrationStore.shared.state.country
        if let existing = storeCountry, let idx = countries.firstIndex(where: { $0.key == existing.key }) {
            selectedCountryIndex = idx
            return idx
        } else if let egyptIdx = countries.firstIndex(where: { $0.key == "EGY" }) {
            selectedCountryIndex = egyptIdx
            return egyptIdx
        }
        return nil
    }

    func selectRestoredCity(from cities: [KeyName]) -> Int {
        if
            let storeCity = RegistrationStore.shared.state.city,
            let idx = cities.firstIndex(where: { $0.key == storeCity.key }) {
            selectedCityIndex = idx
            return idx
        }
        selectedCityIndex = 0
        return 0
    }

    func saveStateToStore(values: PersonalInfoFieldValues) {
        RegistrationStore.shared.update { state in
            state.name = values.name
            state.mobileNumber = values.mobileNumber
            state.mobileNumber2 = values.mobileNumber2
            state.homeNumber = values.homeNumber
            state.email = values.email
            state.password = values.password
            state.confirmPassword = values.confirmPassword
            state.country = values.countryName.isEmpty ? nil : self.countries[safe: self.selectedCountryIndex ?? 0]
            state.city = values.cityName.isEmpty ? nil : self.cities[safe: self.selectedCityIndex ?? 0]
            state.hasCities = !self.cities.isEmpty
            state.region = values.district
            state.address = values.address
        }
    }

    func restoreStateFromStore() -> PersonalInfoFieldValues {
        let state = RegistrationStore.shared.state
        return PersonalInfoFieldValues(
            name: state.name,
            mobileNumber: state.mobileNumber,
            mobileNumber2: state.mobileNumber2,
            homeNumber: state.homeNumber,
            email: state.email,
            password: state.password,
            confirmPassword: state.confirmPassword,
            countryName: state.country?.name ?? "",
            cityName: state.city?.name ?? "",
            district: state.region,
            address: state.address
        )
    }

    func isMandatoryFieldsFilled(values: PersonalInfoFieldValues) -> Bool {
        let personalFilled = values.name.isValid && values.mobileNumber.isValid &&
            values.email.isValid && values.password.isValid && values.confirmPassword.isValid
        let locationFilled: Bool
        if cities.isEmpty {
            locationFilled = values.countryName.isValid && values.district.isValid
        } else {
            locationFilled = values.countryName.isValid && values.cityName.isValid && values.district.isValid
        }
        return personalFilled && locationFilled
    }

    func validateNumber() async -> Bool {
        let state = RegistrationStore.shared.state
        let requestModel = CheckNumberRequestModel(mobileNumber: state.mobileNumber, email: state.email)
        do {
            _ = try await apiProvider.request(.registration(.checkNumber(requestModel)))
            return true
        } catch {
            return false
        }
    }

    func validateField(_ field: PersonalInfoField) -> RegistrationValidationError? {
        let state = RegistrationStore.shared.state
        switch field {
        case .name:
            return state.name.isValid ? nil : .nameEmpty
        case .mobileNumber:
            return state.mobileNumber.isValidPhoneNumber ? nil : .phoneInvalid
        case .mobileNumber2:
            if !state.mobileNumber2.isValidPhoneNumber {
                return .phone2Invalid
            }
            if state.mobileNumber2 == state.mobileNumber {
                return .phone2SameAsPhone1
            }
            return nil
        case .email:
            return state.email.isValidEmail ? nil : .emailInvalid
        case .password:
            return state.password.isValidPassword() ? nil : .passwordTooShort
        case .confirmPassword:
            return (state.password == state.confirmPassword) ? nil : .passwordMismatch
        case .country, .city, .district, .homeNumber, .address:
            return nil
        }
    }

    func validationErrors() -> [RegistrationValidationError] {
        RegistrationValidator.validatePhase1(RegistrationStore.shared.state)
    }

    func navigateToAcademicInfo(from viewController: UIViewController) {
        let academicInfoViewCtrl = StoryboardScene.Registration.academicInfoRegistration.instantiate()
        viewController.navigationController?.pushViewController(academicInfoViewCtrl, animated: true)
    }

    func dismissRegistration(from viewController: UIViewController) {
        RegistrationStore.shared.reset()
        viewController.dismiss(animated: true)
    }
}
