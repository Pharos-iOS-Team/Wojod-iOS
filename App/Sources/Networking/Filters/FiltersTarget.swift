// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation
import Moya

enum FiltersTarget {
    case loadFilteredCourses(isMyCourses: Bool, subjectID: Int, batchID: Int, specializationID: Int?)
}

extension FiltersTarget: TargetType {
    var path: String {
        return "/courses"
    }

    var method: Moya.Method {
        return .get
    }

    var task: Task {
        switch self {
        case let .loadFilteredCourses(isMyCourses, subjectID, batchID, specializationID):
            var parameters: [String: Any] = [:]
            if specializationID == nil {
                parameters = ["my_courses": isMyCourses.description, "subject_id": subjectID, "batch_id": batchID]
            } else {
                parameters = ["my_courses": isMyCourses.description, "subject_id": subjectID, "batch_id": batchID, "specialization_id": specializationID!]
            }
            return .requestParameters(
                parameters: parameters,
                encoding: URLEncoding.queryString
            )
        }
    }
}
