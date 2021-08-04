// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

class FiltersViewModel {
    private let model = HomeModel()
    private let filtersModel = FiltersModel()

    internal func loadAcademicTypes(for academicLevel: AcademicLevel, completion: @escaping ([KeyValue]?) -> Void) {
        NetworkProvider.shared.request(target: .academicTypes(academicLevel.rawValue), type: EducationTypes.self) { response, _ in
            let educationTypes = response?.educationTypes
            completion(educationTypes)
        }
    }

    internal func loadAcademicDivisions(for academicLevel: AcademicLevel, in educationType: Int, completion: @escaping ([Division]?) -> Void) {
        NetworkProvider.shared.request(target: .academicDivisions(academicLevel.rawValue, educationType), type: DivisionsModel.self) { response, _ in
            let divisions = response?.divisions
            completion(divisions)
        }
    }

    internal func loadBatches(for divisionIndex: Int, completion: @escaping ([Batch]?) -> Void) {
        NetworkProvider.shared.request(target: .batches(divisionIndex), type: BatchesModel.self) { response, _ in
            let batches = response?.batches
            completion(batches)
        }
    }

    internal func loadSubjects(forYear yearID: Int, completion: @escaping (Subjects) -> Void) {
        model.loadSubjects(batchID: yearID) { result in
            switch result {
            case .success(let subjects as Subjects):
                completion(subjects)
            default:
                return
            }
        }
    }

    internal func loadSpecializations(for divisionIndex: Int, completion: @escaping ([Specialization]?) -> Void) {
        NetworkProvider.shared.request(target: .specializations(divisionIndex), type: SpecializationsModel.self) { response, _ in
            let specializations = response?.specializations
            completion(specializations)
        }
    }

    internal func loadFilteredCourses(subjectID: Int?, batchID: Int, specializationID: Int?, completion: @escaping (ExploreMoreCoursesResponse?) -> Void) {
        filtersModel.loadFilteredCourses(isMyCourses: false, subjectID: subjectID, batchID: batchID, specializationID: specializationID) { result in
            switch result {
            case .success(let courses as ExploreMoreCoursesResponse):
                completion(courses)
            default:
                return
            }
        }
    }
}
