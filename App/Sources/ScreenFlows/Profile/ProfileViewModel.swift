// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

enum ProfileFields: Int, CaseIterable {
    case name
    case mobileNumber
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
}

class ProfileViewModel {
    let model = ProfileModel()
    let avatarModel = AvatarModel()
    let academicInfoModel = AcademicInfoModel()
    var user: StudentModel?
    var profile = Profile()
    var validFields: [ProfileFields] {
        switch User.shared.educationLevel {
        case EducationLevel.school.rawValue:
            return ProfileFields.allCases.filter { $0 != .specialization }
        case EducationLevel.facutly.rawValue:
            return ProfileFields.allCases.filter { $0 != .parentNumber && $0 != .parentNumber2 }
        case EducationLevel.gradute.rawValue:
            return [.name, .mobileNumber, .email, .homeNumber, .batch, .country, .city, .region, .address]
        default:
            return ProfileFields.allCases
        }
    }

    var successHandler: ((StudentModel) -> Void)?
    var avatarSuccessHandler: ((AvatarsModel) -> Void)?
    var errorHandler: ((WJError) -> Void)?

    func editProfile(id: String) {
        model.editProfile(id: id, profile: profile) { result in
            switch result {
            case .success(let user as StudentModel):
                User.shared.setUserData(user: nil, student: user)
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
        academicInfoModel.fetchEducationalTypes { result in
            switch result {
            case .success(let educationalTypes as EducationalTypesModel):
                AcademicInfo.shared.educationalTypes = educationalTypes
            case .failure(let error):
                self.errorHandler?(error)
            default:
                return
            }
        }
    }

    func fetchDivisions() {
        academicInfoModel.fetchDivisions { result in
            switch result {
            case .success(let divisions as DivisionsModel):
                AcademicInfo.shared.divisions = divisions
            case .failure(let error):
                self.errorHandler?(error)
            default:
                return
            }
        }
    }

    func fetchBatches(id: String) {
        academicInfoModel.fetchBatches(id: id) { result in
            switch result {
            case .success(let batches as BatchesModel):
                AcademicInfo.shared.batches = batches
            case .failure(let error):
                self.errorHandler?(error)
            default:
                return
            }
        }
    }

    func fetchSpecializations(id: String) {
        academicInfoModel.fetchSpecializations(id: id) { result in
            switch result {
            case .success(let specializations as SpecializationsModel):
                AcademicInfo.shared.specializations = specializations
            case .failure(let error):
                self.errorHandler?(error)
            default:
                return
            }
        }
    }

    // swiftlint:disable function_body_length
    func setTextFieldInfo(forIndexPath index: Int) -> String? {
        switch validFields[index] {
        case .name:
            return Language.currentLanguage == .english ? User.shared.nameEn : User.shared.nameAr
        case .mobileNumber:
            return User.shared.mobileNumber
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
        }
    }

    // swiftlint:disable function_body_length
    func editProfileFields(forIndexPath index: Int, withText text: String) {
        switch validFields[index] {
        case .email:
            profile.email = text
        case .country:
            profile.country = text
        case .city:
            profile.city = text
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
        }
    }

    func shouldMakeTextFieldDisabled(forIndexPath index: Int) -> Bool {
        switch validFields[index] {
        case .name, .mobileNumber, .division:
            return true
        default:
            return false
        }
    }

    func setNewPassword(oldPassword: String?, newPassword: String?, passwordConfirmation: String?) {
        profile.oldPassword = oldPassword
        profile.password = newPassword
        profile.passwordConfirmation = passwordConfirmation
    }

    func setNewAvatar(avatarId: Int) {
        profile.avatarId = avatarId
    }
}
