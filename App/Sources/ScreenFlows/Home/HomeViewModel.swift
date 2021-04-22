// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

class HomeViewModel {
    let model = HomeModel()
    private let academicInfoModel = AcademicInfoModel()

    var errorHandler: ((WJError) -> Void)?
    var successHandler: ((StudentModel) -> Void)?
    var showIndicator: (() -> Void)?
    var educationalTypes: EducationalTypesModel?
    var divisions: DivisionsModel?
    var batches: BatchesModel?
    var specializations: SpecializationsModel?

    func fetchUserProfile(id: Int) {
        model.fetchUserProfile(id: id) { result in
            switch result {
            case .success(let user as StudentModel):
                self.setUserData(user)
                self.successHandler?(user)
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

    private func setUserData(_ user: StudentModel) {
        User.shared.setUserData(user: nil, student: user)
    }
}
