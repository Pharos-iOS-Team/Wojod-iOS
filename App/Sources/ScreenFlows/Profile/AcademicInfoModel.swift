// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

class AcademicInfoModel {
    func fetchEducationalTypes(completionHandler: @escaping (Swift.Result<EducationalTypesModel, Error>) -> Void) {
        let requestModel = AcademicInfoRequestModel(
            educationLevel: "\(User.shared.educationLevel)",
            educationType: "\(User.shared.educationType)"
        )
        ApiProvider.shared.request(.academicInfo(.getAcademicType(requestModel)), decodeTo: EducationalTypesModel.self, completion: completionHandler)
    }

    func fetchDivisions(completionHandler: @escaping (Swift.Result<DivisionsModel, Error>) -> Void) {
        let requestModel = AcademicInfoRequestModel(
            educationLevel: "\(User.shared.educationLevel)",
            educationType: "\(User.shared.educationType)"
        )
        ApiProvider.shared.request(.academicInfo(.getDivisions(requestModel)), decodeTo: DivisionsModel.self, completion: completionHandler)
    }

    func fetchBatches(id: String, completionHandler: @escaping (Swift.Result<BatchesModel, Error>) -> Void) {
        ApiProvider.shared.request(.academicInfo(.getBatches(divisionId: id)), decodeTo: BatchesModel.self, completion: completionHandler)
    }

    func fetchSpecializations(id: String, completionHandler: @escaping (Swift.Result<SpecializationsModel, Error>) -> Void) {
        ApiProvider.shared.request(.academicInfo(.getSpecializations(divisionId: id)), decodeTo: SpecializationsModel.self, completion: completionHandler)
    }
}
