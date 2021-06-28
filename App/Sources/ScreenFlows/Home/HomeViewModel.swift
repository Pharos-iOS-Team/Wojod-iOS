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

    func fetchUserProfile(id: Int, completion: @escaping () -> Void) {
        model.fetchUserProfile(id: id) { result in
            switch result {
            case .success(let user as StudentModel):
                self.setUserData(user)
                self.successHandler?(user)
                completion()
            case .failure(let error):
                self.errorHandler?(error)
            default:
                return
            }
        }
    }

    func loadSubjects(batchID: Int, completion: @escaping (Subjects?) -> Void) {
        model.loadSubjects(batchID: batchID) { result in
            switch result {
            case .success(let subjects as Subjects):
                completion(subjects)
            default:
                return
            }
        }
    }

    func loadRelatedCourses(isMyCourses: Bool, subjectID: Int, completion: @escaping (RelatedCoursesResponse?) -> Void) {
        model.loadRelatedCourses(isMyCourses: isMyCourses, subjectID: subjectID) { result in
            switch result {
            case .success(let relatedCourses as RelatedCoursesResponse):
                completion(relatedCourses)
            default:
                return
            }
        }
    }

    func loadExploreMoreCourses(isMyCourses: Bool, completion: @escaping (ExploreMoreCoursesResponse?) -> Void) {
        model.loadExploreMoreCourses(isMyCourses: isMyCourses) { result in
            switch result {
            case .success(let exploreMoreCourses as ExploreMoreCoursesResponse):
                completion(exploreMoreCourses)
            default:
                return
            }
        }
    }

    func searchCourses(value: String, completion: @escaping (ExploreMoreCoursesResponse?) -> Void) {
        model.searchCourses(value: value) { result in
            switch result {
            case .success(let resultCourses as ExploreMoreCoursesResponse):
                completion(resultCourses)
            default:
                return
            }
        }
    }

    private func setUserData(_ user: StudentModel) {
        User.shared.setUserData(user: user.student)
    }
}
