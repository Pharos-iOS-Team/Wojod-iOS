// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

class ProfileModel {
    func editProfile(id: String, profile: Profile, completionHandler: @escaping (Swift.Result<ApiResponse<UserModel>, Error>) -> Void) {
        ApiProvider.shared.request(.profile(.editProfile(id: id, profile: profile)), decodeTo: ApiResponse<UserModel>.self, completion: completionHandler)
    }

    func fetchDivisions(academicLevel: Int, academicType: Int, completionHandler: @escaping (Swift.Result<ApiResponse<[Division]>, Error>) -> Void) {
        let requestModel = AcademicInfoRequestModel(educationLevel: String(academicLevel), educationType: String(academicType))
        ApiProvider.shared.request(.profile(.fetchDivisions(requestModel)), decodeTo: ApiResponse<[Division]>.self, completion: completionHandler)
    }

    func fetchBatches(id: String, completionHandler: @escaping (Swift.Result<ApiResponse<[KeyValue]>, Error>) -> Void) {
        ApiProvider.shared.request(.profile(.fetchBatches(id: id)), decodeTo: ApiResponse<[KeyValue]>.self, completion: completionHandler)
    }

    func fetchSpecializations(id: String, completionHandler: @escaping (Swift.Result<ApiResponse<[KeyValue]>, Error>) -> Void) {
        ApiProvider.shared.request(.profile(.fetchSpecializations(id: id)), decodeTo: ApiResponse<[KeyValue]>.self, completion: completionHandler)
    }
}
