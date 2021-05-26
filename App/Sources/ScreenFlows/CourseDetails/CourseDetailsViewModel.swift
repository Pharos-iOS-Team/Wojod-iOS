// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

class CourseDetailsViewModel {
    let model = CourseDetailsModel()

    func loadLessons(courseID: Int, completion: @escaping (LessonsModel) -> Void) {
        model.loadLessons(courseID: courseID) { result in
            switch result {
            case .success(let lessons as LessonsModel):
                completion(lessons)
            default:
                return
            }
        }
    }
}
