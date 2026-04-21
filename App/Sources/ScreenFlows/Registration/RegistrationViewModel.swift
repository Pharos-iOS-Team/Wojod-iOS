// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

internal enum AcademicLevel: Int {
    case schoolStudent
    case universityStudent
    case graduate
}

internal class RegistrationViewModel {
    internal var countryCodes = [String]()
    internal var cityCodes = [String]()
    internal var divisionIDs = [Int]()
    internal var batchesIDs = [Int]()
    internal var specializationsIDs = [Int]()
    internal var divisions: [Division]?

    internal func checkNumberIfValid(_ mobileNumber: String, email: String, completion: @escaping (Bool) -> Void) {
        let requestModel = CheckNumberRequestModel(mobileNumber: mobileNumber, email: email)
        ApiProvider.shared.request(.registration(.checkNumber(requestModel))) { result in
            switch result {
            case .success:
                completion(true)
            case .failure:
                completion(false)
            }
        }
    }

    internal func loadCountries(completion: @escaping ([KeyName]?) -> Void) {
        ApiProvider.shared.request(.registration(.countries), decodeTo: DataResponse.self) { result in
            switch result {
            case let .success(response):
                let countryData = response.data
                self.countryCodes = countryData.compactMap { $0.key }
                completion(countryData)
            case .failure:
                completion(nil)
            }
        }
    }

    internal func loadCities(for selectedCountry: String, completion: @escaping ([KeyName]?) -> Void) {
        let requestModel = CitiesRequestModel(selectedCountry: selectedCountry)
        ApiProvider.shared.request(.registration(.cities(requestModel)), decodeTo: DataResponse.self) { result in
            switch result {
            case let .success(response):
                let cities = response.data
                self.cityCodes = cities.compactMap { $0.key }
                completion(cities)
            case .failure:
                completion(nil)
            }
        }
    }

    internal func loadAcademicTypes(for academicLevel: AcademicLevel, completion: @escaping ([KeyValue]?) -> Void) {
        let requestModel = AcademicRequestModel(educationLevel: academicLevel.rawValue)
        ApiProvider.shared.request(.registration(.academicTypes(requestModel)), decodeTo: EducationTypes.self) { result in
            switch result {
            case let .success(response):
                completion(response.educationTypes)
            case .failure:
                completion(nil)
            }
        }
    }

    internal func loadAcademicDivisions(for academicLevel: AcademicLevel, in educationType: Int, completion: @escaping ([Division]?) -> Void) {
        let requestModel = AcademicRequestModel(
            educationLevel: academicLevel.rawValue,
            educationType: academicLevel == .schoolStudent ? educationType : nil,
            loginOrganization: academicLevel == .schoolStudent ? nil : AppEnvironment.appName.loginOrganization
        )
        ApiProvider.shared.request(.registration(.academicDivisions(requestModel)), decodeTo: DivisionsModel.self) { result in
            switch result {
            case let .success(response):
                let divisions = response.divisions
                self.divisions = divisions
                self.divisionIDs = divisions?.compactMap { $0.key } ?? []
                completion(divisions)
            case .failure:
                completion(nil)
            }
        }
    }

    internal func loadBatches(for divisionIndex: Int, completion: @escaping ([Batch]?) -> Void) {
        ApiProvider.shared.request(.registration(.batches(divisionID: divisionIndex)), decodeTo: BatchesModel.self) { result in
            switch result {
            case let .success(response):
                let batches = response.batches
                self.batchesIDs = batches.compactMap { $0.key }
                completion(batches)
            case .failure:
                completion(nil)
            }
        }
    }

    internal func loadSpecializations(for divisionIndex: Int, completion: @escaping ([Specialization]?) -> Void) {
        ApiProvider.shared.request(.registration(.specializations(divisionID: divisionIndex)), decodeTo: SpecializationsModel.self) { result in
            switch result {
            case let .success(response):
                let specializations = response.specializations
                self.specializationsIDs = specializations?.compactMap { $0.key } ?? []
                completion(specializations)
            case .failure:
                completion(nil)
            }
        }
    }

    internal func loadAvatars(completion: @escaping ([Avatar]) -> Void) {
        ApiProvider.shared.request(.profile(.getAvatars), decodeTo: AvatarsModel.self) { result in
            switch result {
            case let .success(response):
                completion(response.avatars)
            case .failure:
                completion([])
            }
        }
    }

    internal func signUp(user: UserSignupRequest, completion: @escaping (Bool, String?) -> Void) {
        ApiProvider.shared.request(.registration(.signUp(user))) { result in
            switch result {
            case .success:
                completion(true, nil)
            case let .failure(error):
                let message = (error as? ApiError)?.errorDescription
                completion(false, message)
            }
        }
    }
}
