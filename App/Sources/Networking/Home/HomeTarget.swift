// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation
import Moya

enum HomeTarget {
    case loadSubjects(batchID: Int)
    case loadRelatedCourses(isMyCourses: Bool, subjectID: Int?, page: Int, limit: Int)
    case loadExploreMoreCourses(isMyCourses: Bool, page: Int, limit: Int)
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
        case let .loadRelatedCourses(isMyCourses, subjectID, page, limit):
            var parameters: [String: Any] = [:]
            if let subjectID = subjectID {
                parameters = ["my_courses": isMyCourses.description, "subject_id": subjectID, "page": page, "limit": limit]
            } else {
                parameters = ["my_courses": isMyCourses.description, "page": page, "limit": limit]
            }
            return .requestParameters(
                parameters: parameters,
                encoding: URLEncoding.queryString
            )
        case let .loadExploreMoreCourses(isMyCourses, page, limit):
            return .requestParameters(
                parameters: ["my_courses": isMyCourses.description, "page": page, "limit": limit],
                encoding: URLEncoding.queryString
            )
        case let .searchCourses(value):
            return .requestParameters(parameters: ["value": value], encoding: URLEncoding.queryString)
        default:
            return .requestPlain
        }
    }
}
