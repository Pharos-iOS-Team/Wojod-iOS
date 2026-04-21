// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

class ProfileModel {
    func editProfile(id: String, profile: Profile, completionHandler: @escaping (Swift.Result<StudentModel, Error>) -> Void) {
        ApiProvider.shared.request(.profile(.editProfile(id: id, profile: profile)), decodeTo: StudentModel.self, completion: completionHandler)
    }

    func fetchDivisions(academicLevel: Int, academicType: Int, completionHandler: @escaping (Swift.Result<DivisionsModel, Error>) -> Void) {
        let requestModel = AcademicInfoRequestModel(educationLevel: String(academicLevel), educationType: String(academicType))
        ApiProvider.shared.request(.profile(.fetchDivisions(requestModel)), decodeTo: DivisionsModel.self, completion: completionHandler)
    }

    func fetchBatches(id: String, completionHandler: @escaping (Swift.Result<BatchesModel, Error>) -> Void) {
        ApiProvider.shared.request(.profile(.fetchBatches(id: id)), decodeTo: BatchesModel.self, completion: completionHandler)
    }

    func fetchSpecializations(id: String, completionHandler: @escaping (Swift.Result<SpecializationsModel, Error>) -> Void) {
        ApiProvider.shared.request(.profile(.fetchSpecializations(id: id)), decodeTo: SpecializationsModel.self, completion: completionHandler)
    }
}
