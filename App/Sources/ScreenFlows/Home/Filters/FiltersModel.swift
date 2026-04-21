// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

class FiltersModel {
    func loadFilteredCourses(
        isMyCourses: Bool,
        subjectID: Int?,
        batchID: Int,
        specializationID: Int?,
        completion: @escaping (Swift.Result<CoursesResponse, Error>) -> Void
    ) {
        let requestModel = FilteredCoursesRequestModel(
            isMyCourses: isMyCourses,
            subjectID: subjectID,
            batchID: batchID,
            specializationID: specializationID
        )
        ApiProvider.shared.request(.home(.loadFilteredCourses(requestModel)), decodeTo: CoursesResponse.self, completion: completion)
    }
}
