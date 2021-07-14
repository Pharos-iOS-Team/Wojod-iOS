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
    var relatedCoursesPage: Int = 1
    var exploreMorePage: Int = 1
    var limit: Int = 10

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

    func loadRelatedCourses(isBeingScrolled: Bool, isMyCourses: Bool, subjectID: Int?, completion: @escaping (RelatedCoursesResponse?) -> Void) {
        model.loadRelatedCourses(isMyCourses: isMyCourses, subjectID: subjectID, page: relatedCoursesPage, limit: limit) { result in
            switch result {
            case .success(let relatedCourses as RelatedCoursesResponse):
                completion(relatedCourses)
                if isBeingScrolled {
                    self.relatedCoursesPage += 1
                } else {
                    self.relatedCoursesPage = 1
                }
            default:
                return
            }
        }
    }

    func loadExploreMoreCourses(isBeingScrolled: Bool, isMyCourses: Bool, completion: @escaping (ExploreMoreCoursesResponse?) -> Void) {
        model.loadExploreMoreCourses(isMyCourses: isMyCourses, page: exploreMorePage, limit: limit) { result in
            switch result {
            case .success(let exploreMoreCourses as ExploreMoreCoursesResponse):
                completion(exploreMoreCourses)
                if isBeingScrolled {
                    self.exploreMorePage += 1
                } else {
                    self.exploreMorePage = 1
                }
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
