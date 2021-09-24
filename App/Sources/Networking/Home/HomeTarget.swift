// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation
import Moya

enum HomeTarget {
    case loadSubjects(batchID: Int)
    case loadRelatedCourses(isMyCourses: Bool, subjectID: Int?, page: Int, limit: Int)
    case loadExploreMoreCourses(isMyCourses: Bool, page: Int, limit: Int)
    case searchCourses(value: String)
    case loadRelatedCoursesForTeacher(teacherID: Int, subjectID: Int, isMyCourses: Bool, page: Int, limit: Int)
    case loadAdvertisements
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
        case let .loadRelatedCoursesForTeacher(teacherID, _, _, _, _):
            return "/teachers/\(teacherID)/related_courses"
        case .loadAdvertisements:
            return "/advertisements"
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
                parameters = [
                    "my_courses": isMyCourses.description,
                    "subject_id": subjectID,
                    "page": page,
                    "limit": limit,
                    "locale": Language.currentLanguage.rawValue
                ]
            } else {
                parameters = ["my_courses": isMyCourses.description, "page": page, "limit": limit, "locale": Language.currentLanguage.rawValue]
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
        case let .loadRelatedCoursesForTeacher(_, subjectID, isMyCourses, page, limit):
            return .requestParameters(
                parameters: ["subject_id": subjectID, "my_courses": isMyCourses, "page": page, "limit": limit],
                encoding: URLEncoding.queryString
            )
        default:
            return .requestPlain
        }
    }
}
