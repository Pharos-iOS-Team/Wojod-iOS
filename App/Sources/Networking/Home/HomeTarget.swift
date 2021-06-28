// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation
import Moya

enum HomeTarget {
    case loadSubjects(batchID: Int)
    case loadRelatedCourses(isMyCourses: Bool, subjectID: Int)
    case loadExploreMoreCourses(isMyCourses: Bool)
    case searchCourses(value: String)
}

extension HomeTarget: TargetType {
    var path: String {
        switch self {
        case let .loadSubjects(batchID):
            return "/batches/\(batchID)/subjects"
        case .loadRelatedCourses:
            return "/related_courses"
        case .loadExploreMoreCourses:
            return "/courses"
        case .searchCourses:
            return "/courses/search"
        }
    }

    var method: Moya.Method {
        return .get
    }

    var task: Task {
        switch self {
        case let .loadRelatedCourses(isMyCourses, subjectID):
            return .requestParameters(parameters: ["my_courses": isMyCourses, "subject_id": subjectID], encoding: URLEncoding.queryString)
        case let .loadExploreMoreCourses(isMyCourses):
            return .requestParameters(parameters: ["my_courses": isMyCourses], encoding: URLEncoding.queryString)
        case let .searchCourses(value):
            return .requestParameters(parameters: ["value": value], encoding: URLEncoding.queryString)
        default:
            return .requestPlain
        }
    }
}
