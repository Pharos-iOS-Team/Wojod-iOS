// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

class AcademicInfoModel {
    func fetchEducationalTypes(completionHandler: @escaping (Swift.Result<ApiResponse<[KeyValue]>, Error>) -> Void) {
        let requestModel = AcademicInfoRequestModel(
            educationLevel: "\(User.shared.educationLevel)",
            educationType: "\(User.shared.educationType)"
        )
        ApiProvider.shared.request(.academicInfo(.getAcademicType(requestModel)), decodeTo: ApiResponse<[KeyValue]>.self, completion: completionHandler)
    }

    func fetchDivisions(completionHandler: @escaping (Swift.Result<ApiResponse<[Division]>, Error>) -> Void) {
        let requestModel = AcademicInfoRequestModel(
            educationLevel: "\(User.shared.educationLevel)",
            educationType: "\(User.shared.educationType)"
        )
        ApiProvider.shared.request(.academicInfo(.getDivisions(requestModel)), decodeTo: ApiResponse<[Division]>.self, completion: completionHandler)
    }

    func fetchBatches(id: String, completionHandler: @escaping (Swift.Result<ApiResponse<[KeyValue]>, Error>) -> Void) {
        ApiProvider.shared.request(.academicInfo(.getBatches(divisionId: id)), decodeTo: ApiResponse<[KeyValue]>.self, completion: completionHandler)
    }

    func fetchSpecializations(id: String, completionHandler: @escaping (Swift.Result<ApiResponse<[KeyValue]>, Error>) -> Void) {
        ApiProvider.shared.request(.academicInfo(.getSpecializations(divisionId: id)), decodeTo: ApiResponse<[KeyValue]>.self, completion: completionHandler)
    }
}
