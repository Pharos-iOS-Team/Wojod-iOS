// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation
import Moya

enum CourseDetailsTarget {
    case loadLessons(courseID: Int)
}

extension CourseDetailsTarget: TargetType {
    var path: String {
        switch self {
        case let .loadLessons(courseID):
            return "/courses/\(courseID)/lessons"
        }
    }

    var method: Moya.Method {
        return .get
    }

    var task: Task {
        return .requestPlain
    }
}
