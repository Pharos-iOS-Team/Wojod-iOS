// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

class HomeViewModel {
    let model = HomeModel()
    private let academicInfoModel = AcademicInfoModel()

    var errorHandler: ((WJError) -> Void)?
    var successHandler: ((StudentModel) -> Void)?
    var showIndicator: (() -> Void)?
    var page: Int = 1
    var courses: [SubjectCourses] = []
    private(set) var subjects: [Subject] = []
    var isMyCourses: Bool = false
    var selectedSubject: Subject?

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

    func loadCourses(mode: HomeMode, completion: @escaping () -> Void) {
        let requestModel = CoursesRequestModel(type: mode, isMyCourses: isMyCourses, subjectID: selectedSubject?.id, page: page)
        model.loadCourses(requestModel: requestModel) { result in
            switch result {
            case let .success(courses as CoursesResponse):
                self.parseCoursesResponse(courses)
                self.page += 1
                completion()
            default:
                return
            }
        }
    }

    private func parseCoursesResponse(_ coursesResponse: CoursesResponse) {
        if let subjects = coursesResponse.subjects {
            self.subjects = subjects
        }
        if page == 1 {
            courses.removeAll()
        }
        if let exploreCourses = coursesResponse.teachersCourses {
            courses.append(contentsOf: exploreCourses)
        }
    }

    func searchCourses(value: String, completion: @escaping () -> Void) {
        model.searchCourses(value: value) { result in
            switch result {
            case let .success(resultCourses as CoursesResponse):
                self.courses = resultCourses.teachersCourses ?? []
                completion()
            default:
                return
            }
        }
    }

    func loadAds(completion: @escaping (Advertisements?) -> Void) {
        model.loadAds { result in
            switch result {
            case .success(let advertisements as Advertisements):
                completion(advertisements)
            default:
                return
            }
        }
    }

    private func setUserData(_ user: StudentModel) {
        User.shared.setUserData(user: user.student)
    }
}
