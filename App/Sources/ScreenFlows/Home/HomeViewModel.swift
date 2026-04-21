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
            case .success(let user):
                self.setUserData(user)
                self.successHandler?(user)
            case .failure(let error):
                self.errorHandler?(WJError(type: .parsingError, message: error.localizedDescription))
            }
        }
    }

    func loadCourses(mode: HomeMode, completion: @escaping () -> Void) {
        let requestModel = CoursesRequestModel(
            type: mode,
            myCourses: isMyCourses,
            subjectID: selectedSubject?.id,
            page: page,
            locale: Language.currentLanguage.rawValue
        )
        model.loadCourses(requestModel: requestModel) { result in
            switch result {
            case .success(let courses):
                self.parseCoursesResponse(courses)
                self.page += 1
                completion()
            case .failure:
                break
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
            case .success(let resultCourses):
                self.courses = resultCourses.teachersCourses ?? []
                completion()
            case .failure:
                break
            }
        }
    }

    func loadAds(completion: @escaping (Advertisements?) -> Void) {
        model.loadAds { result in
            switch result {
            case .success(let advertisements):
                completion(advertisements)
            case .failure:
                completion(nil)
            }
        }
    }

    private func setUserData(_ user: StudentModel) {
        User.shared.setUserData(user: user.student)
    }
}
