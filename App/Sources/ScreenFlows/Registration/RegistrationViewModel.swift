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
    internal var academicTypeIDs = [Int]()
    internal var divisionIDs = [Int]()
    internal var batchesIDs = [Int]()

    internal func checkNumberIfValid(_ mobileNumber: String, completion: @escaping (Bool) -> Void) {
        NetworkProvider.shared.request(target: .checkNumber(mobileNumber)) { statusCode, _ in
            completion(statusCode == 200)
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

    internal func loadCities(for countryIndex: Int, completion: @escaping ([String]) -> Void) {
        let selectedCountry = countryCodes[countryIndex]
        NetworkProvider.shared.request(target: .cities(selectedCountry), type: DataResponse.self) { response, _ in
            let cities = response?.data
            self.cityCodes = cities?.compactMap { $0.key } ?? []
            if let cityNames = cities?.compactMap({ $0.name }) {
                completion(cityNames)
            }
        }
    }

    internal func loadAcademicTypes(for academicLevel: AcademicLevel, completion: @escaping ([String]) -> Void) {
        NetworkProvider.shared.request(target: .academicTypes(academicLevel.rawValue), type: EducationTypes.self) { response, _ in
            let educationTypes = response?.educationTypes
            self.academicTypeIDs = educationTypes?.compactMap { $0.key } ?? []
            if let educationTypesList = educationTypes?.compactMap({ $0.value }) {
                completion(educationTypesList)
            }
        }
    }

    internal func loadAcademicDivisions(for academicLevel: AcademicLevel, completion: @escaping ([String]) -> Void) {
        NetworkProvider.shared.request(target: .academicDivisions(academicLevel.rawValue), type: Divisions.self) { response, _ in
            let divisions = response?.divisions
            self.divisionIDs = divisions?.compactMap { $0.key } ?? []
            if let divisionNames = divisions?.compactMap({ $0.value }) {
                completion(divisionNames)
            }
        }
    }

    internal func loadBatches(for divisionIndex: Int, completion: @escaping ([String]) -> Void) {
        let divisionID = self.divisionIDs[divisionIndex]
        NetworkProvider.shared.request(target: .batches(divisionID), type: Batches.self) { response, _ in
            let batches = response?.batches
            self.batchesIDs = batches?.compactMap { $0.key } ?? []
            if let batchesList = batches?.compactMap({ $0.value }) {
                completion(batchesList)
            }
        }
    }

    internal func loadSpecializations(for divisionIndex: Int, completion: @escaping ([String]) -> Void) {
        let divisionID = self.divisionIDs[divisionIndex]
        NetworkProvider.shared.request(target: .specializations(divisionID), type: Specializations.self) { response, _ in
            let specializations = response?.specializations
            if let specializationsList = specializations?.compactMap({ $0.value }) {
                completion(specializationsList)
            }
        }
    }

    internal func loadAvatars(completion: @escaping ([Avatar]) -> Void) {
        NetworkProvider.shared.request(target: .avatars, type: Avatars.self) { response, _ in
            completion(response?.avatars ?? [])
        }
    }

    internal func signUp(user: UserSignupRequest, completion: @escaping (Bool, Error?) -> Void) {
        NetworkProvider.shared.request(target: .signUp(user)) { response, error in
            let isSignupSuccessful = response == 200 ? true : false
            completion(isSignupSuccessful, error)
        }
    }
}
