// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

enum ProfileFields: Int, CaseIterable {
    case name
    case mobileNumber
    case mobileNumber2
    case email
    case parentNumber
    case parentNumber2
    case homeNumber
    case academicType
    case division
    case batch
    case specialization
    case country
    case city
    case region
    case address
    case logout
}

class ProfileViewModel {
    let model = ProfileModel()
    let avatarModel = AvatarModel()
    let academicInfoModel = AcademicInfoModel()
    var user: StudentModel?
    var profile = Profile()
    var countries = [KeyName]()
    var cities = [KeyName]()
    var validFields: [ProfileFields] {
        switch User.shared.educationLevel {
        case EducationLevel.school.rawValue:
            return ProfileFields.allCases.filter { $0 != .specialization }
        case EducationLevel.facutly.rawValue:
            return ProfileFields.allCases.filter { $0 != .parentNumber && $0 != .parentNumber2 }
        case EducationLevel.gradute.rawValue:
            return [.name, .mobileNumber, .mobileNumber2, .email, .homeNumber, .batch, .division, .country, .city, .region, .address, .logout]
        default:
            return ProfileFields.allCases
        }
    }

    var successHandler: ((StudentModel) -> Void)?
    var academicInfoSuccessHandler: (() -> Void)?
    var avatarSuccessHandler: ((AvatarsModel) -> Void)?
    var errorHandler: ((WJError) -> Void)?
    var reloadCountriesCell: (() -> Void)?
    var reloadCitiesCell: ((Int) -> Void)?
    private let group = DispatchGroup()

    func editProfile(id: String) {
        model.editProfile(id: id, profile: profile) { result in
            switch result {
            case .success(let user as StudentModel):
                User.shared.setUserData(user: user.student)
                self.successHandler?(user)
            case .failure(let error):
                self.errorHandler?(error)
            default:
                return
            }
        }
    }

    func fetchAvatars() {
        avatarModel.fetchAvatars { result in
            switch result {
            case .success(let avatars as AvatarsModel):
                self.avatarSuccessHandler?(avatars)
            case .failure(let error):
                self.errorHandler?(error)
            default:
                return
            }
        }
    }

    func fetchEducationalTypes() {
        group.enter()
        academicInfoModel.fetchEducationalTypes { result in
            switch result {
            case .success(let educationalTypes as EducationalTypesModel):
                AcademicInfo.shared.educationalTypes = educationalTypes
                self.handleSuccessfulResponse()
            case .failure(let error):
                self.errorHandler?(error)
            default:
                return
            }
            self.group.leave()
        }
    }

    func fetchDivisions() {
        group.enter()
        academicInfoModel.fetchDivisions { result in
            switch result {
            case .success(let divisions as DivisionsModel):
                AcademicInfo.shared.divisions = divisions
                self.handleSuccessfulResponse()
            case .failure(let error):
                self.errorHandler?(error)
            default:
                return
            }
            self.group.leave()
        }
    }

    func fetchBatches(id: String) {
        group.enter()
        academicInfoModel.fetchBatches(id: id) { result in
            switch result {
            case .success(let batches as BatchesModel):
                AcademicInfo.shared.batches = batches
                self.handleSuccessfulResponse()
            case .failure(let error):
                self.errorHandler?(error)
            default:
                return
            }
            self.group.leave()
        }
    }

    func fetchSpecializations(id: String) {
        group.enter()
        academicInfoModel.fetchSpecializations(id: id) { result in
            switch result {
            case .success(let specializations as SpecializationsModel):
                AcademicInfo.shared.specializations = specializations
                self.handleSuccessfulResponse()
            case .failure(let error):
                self.errorHandler?(error)
            default:
                return
            }
            self.group.leave()
        }
    }

    func loadCountries() {
        NetworkProvider.shared.request(target: .countries, type: DataResponse.self) { response, _ in
            let countries = response?.data
            self.countries = countries ?? [KeyName]()
            self.reloadCountriesCell?()
        }
    }

    func loadCities(for selectedCountry: String, index: Int) {
        NetworkProvider.shared.request(target: .cities(selectedCountry), type: DataResponse.self) { response, _ in
            let cities = response?.data
            self.cities = cities ?? [KeyName]()
            User.shared.city = cities?.first?.name
            self.profile.city = cities?.first?.key
            self.reloadCitiesCell?(index + 1)
        }
    }

    // swiftlint:disable function_body_length
    func setTextFieldInfo(forIndexPath index: Int) -> String? {
        switch validFields[index] {
        case .name:
            return User.shared.name
        case .mobileNumber:
            return User.shared.mobileNumber
        case .mobileNumber2:
            return User.shared.mobileNumber2
        case .email:
            return User.shared.email
        case .academicType:
            return User.shared.educationTypeName
        case .parentNumber:
            return User.shared.parentNumber
        case .division:
            return User.shared.divisionName
        case .batch:
            return User.shared.batchName
        case .country:
            return User.shared.country
        case .city:
            return User.shared.city
        case .region:
            return User.shared.region
        case .address:
            return User.shared.address
        case .specialization:
            return User.shared.specializationName
        case .homeNumber:
            return User.shared.homeNumber
        case .parentNumber2:
            return User.shared.parentNumber2
        case .logout:
            return nil
        }
    }

    // swiftlint:disable function_body_length
    func editProfileFields(forIndexPath index: Int, withText text: String) {
        switch validFields[index] {
        case .email:
            profile.email = text
        case .country:
            guard let countryCode = countries.first { $0.name == text }?.key else { return }
            profile.country = countries.first { $0.name == text }?.key
            User.shared.country = countries.first { $0.name == text }?.name
            loadCities(for: countryCode, index: index)
        case .city:
            profile.city = cities.first { $0.name == text }?.key
        case .region:
            profile.region = text
        case .address:
            profile.address = text
        case .batch:
            profile.batchId = AcademicInfo.shared.batches?.batches.first { $0.value == text }?.key
        case .specialization:
            profile.specializationId = AcademicInfo.shared.specializations?.specializations.first { $0.value == text }?.key
        case .homeNumber:
            profile.homeNumber = text
        case .parentNumber:
            profile.parent1PhoneNumber = text
        case .parentNumber2:
            profile.parent2PhoneNumber = text
        case .name:
            profile.name = text
        case .mobileNumber2:
            profile.mobileNumber2 = text
        default:
            return
        }
    }

    // swiftlint:disable function_body_length
    func setTextfieldLabel(forIndexPath index: Int) -> String {
        switch validFields[index] {
        case .name:
            return L10n.Profile.name
        case .mobileNumber:
            return L10n.Profile.mobileNumber
        case .email:
            return L10n.Profile.email
        case .parentNumber:
            return L10n.Profile.parentNumber
        case .parentNumber2:
            return L10n.Profile.parentNumber2
        case .academicType:
            return L10n.Profile.academicType
        case .batch:
            return L10n.Profile.batch
        case .division:
            return L10n.Profile.division
        case .specialization:
            return L10n.Profile.specialization
        case .homeNumber:
            return L10n.Profile.homePhone
        case .country:
            return L10n.Profile.country
        case .city:
            return L10n.Profile.city
        case .region:
            return L10n.Profile.region
        case .address:
            return L10n.Profile.address
        case .mobileNumber2:
            return L10n.Profile.mobileNumber2
        case .logout:
            return ""
        }
    }

    func shouldMakeTextFieldDisabled(forIndexPath index: Int) -> Bool {
        validFields[index] == .mobileNumber
    }

    func setNewPassword(oldPassword: String?, newPassword: String?, passwordConfirmation: String?) {
        profile.oldPassword = oldPassword
        profile.password = newPassword
        profile.passwordConfirmation = passwordConfirmation
    }

    func setNewAvatar(avatarId: Int) {
        profile.avatarId = avatarId
    }

    func handleSuccessfulResponse() {
        group.notify(queue: .main) {
            self.academicInfoSuccessHandler?()
        }
    }
}
