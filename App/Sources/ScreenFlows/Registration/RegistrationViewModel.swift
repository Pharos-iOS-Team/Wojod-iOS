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
        NetworkProvider.shared.request(target: .checkNumber(mobileNumber, email)) { response, _ in
            completion(response?.statusCode == 200)
        }
    }

    internal func loadCountries(completion: @escaping ([String]) -> Void) {
        NetworkProvider.shared.request(target: .countries, type: DataResponse.self) { response, _ in
            let countryData = response?.data
            self.countryCodes = countryData?.compactMap { $0.key } ?? []
            if let countryNames = countryData?.compactMap({ $0.name }) {
                completion(countryNames)
            }
        }
    }

    internal func loadCities(for selectedCountry: String, completion: @escaping ([String]) -> Void) {
        NetworkProvider.shared.request(target: .cities(selectedCountry), type: DataResponse.self) { response, _ in
            let cities = response?.data
            self.cityCodes = cities?.compactMap { $0.key } ?? []
            if let cityNames = cities?.compactMap({ $0.name }) {
                completion(cityNames)
            }
        }
    }

    internal func loadAcademicTypes(for academicLevel: AcademicLevel, completion: @escaping ([KeyValue]?) -> Void) {
        NetworkProvider.shared.request(target: .academicTypes(academicLevel.rawValue), type: EducationTypes.self) { response, _ in
            let educationTypes = response?.educationTypes
            completion(educationTypes)
        }
    }

    internal func loadAcademicDivisions(for academicLevel: AcademicLevel, in educationType: Int, completion: @escaping ([String]) -> Void) {
        NetworkProvider.shared.request(target: .academicDivisions(academicLevel.rawValue, educationType), type: DivisionsModel.self) { response, _ in
            let divisions = response?.divisions
            self.divisions = divisions
            self.divisionIDs = divisions?.compactMap { $0.key } ?? []
            if let divisionNames = divisions?.compactMap({ $0.value }) {
                completion(divisionNames)
            }
        }
    }

    internal func loadBatches(for divisionIndex: Int, completion: @escaping ([String]) -> Void) {
        NetworkProvider.shared.request(target: .batches(divisionIndex), type: BatchesModel.self) { response, _ in
            let batches = response?.batches
            self.batchesIDs = batches?.compactMap { $0.key } ?? []
            if let batchesList = batches?.compactMap({ $0.value }) {
                completion(batchesList)
            }
        }
    }

    internal func loadSpecializations(for divisionIndex: Int, completion: @escaping ([String]) -> Void) {
        NetworkProvider.shared.request(target: .specializations(divisionIndex), type: SpecializationsModel.self) { response, _ in
            let specializations = response?.specializations
            self.specializationsIDs = specializations?.compactMap { $0.key } ?? []
            if let specializationsList = specializations?.compactMap({ $0.value }) {
                completion(specializationsList)
            }
        }
    }

    internal func loadAvatars(completion: @escaping ([Avatar]) -> Void) {
        NetworkProvider.shared.request(target: .avatars, type: AvatarsModel.self) { response, _ in
            completion(response?.avatars ?? [])
        }
    }

    internal func signUp(user: UserSignupRequest, completion: @escaping (Bool, String?) -> Void) {
        NetworkProvider.shared.request(target: .signUp(user)) { response, error in
            if error == nil {
                completion(response?.statusCode == 200, nil)
            } else {
                completion(false, error?.errors?[0])
            }
        }
    }
}
