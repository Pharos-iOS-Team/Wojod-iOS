// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

class FiltersViewModel {
    private let apiProvider: ApiProvider

    init(apiProvider: ApiProvider = .shared) {
        self.apiProvider = apiProvider
    }

    internal func loadAcademicTypes(for academicLevel: AcademicLevel, completion: @escaping ([KeyValue]?) -> Void) {
        let requestModel = AcademicRequestModel(educationLevel: academicLevel.rawValue)
        apiProvider.request(.registration(.academicTypes(requestModel)), decodeTo: EducationTypes.self) { result in
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
        apiProvider.request(.registration(.academicDivisions(requestModel)), decodeTo: DivisionsModel.self) { result in
            switch result {
            case let .success(response):
                completion(response.divisions)
            case .failure:
                completion(nil)
            }
        }
    }

    internal func loadBatches(for divisionIndex: Int, completion: @escaping ([Batch]?) -> Void) {
        apiProvider.request(.registration(.batches(divisionID: divisionIndex)), decodeTo: BatchesModel.self) { result in
            switch result {
            case let .success(response):
                completion(response.batches)
            case .failure:
                completion(nil)
            }
        }
    }

    internal func loadSubjects(forYear yearID: Int, completion: @escaping (Subjects) -> Void) {
        apiProvider.request(.home(.loadSubjects(batchID: yearID)), decodeTo: Subjects.self) { result in
            switch result {
            case .success(let subjects):
                completion(subjects)
            case .failure:
                return
            }
        }
    }

    func loadSpecializations(for divisionIndex: Int, completion: @escaping ([Specialization]?) -> Void) {
        apiProvider.request(.registration(.specializations(divisionID: divisionIndex)), decodeTo: SpecializationsModel.self) { result in
            switch result {
            case let .success(response):
                completion(response.specializations)
            case .failure:
                completion(nil)
            }
        }
    }

    func loadFilteredCourses(subjectID: Int?, batchID: Int, specializationID: Int?, completion: @escaping (CoursesResponse?) -> Void) {
        let requestModel = FilteredCoursesRequestModel(
            isMyCourses: false,
            subjectID: subjectID,
            batchID: batchID,
            specializationID: specializationID
        )
        apiProvider.request(.home(.loadFilteredCourses(requestModel)), decodeTo: CoursesResponse.self) { result in
            switch result {
            case .success(let courses):
                completion(courses)
            case .failure:
                completion(nil)
            }
        }
    }
}
