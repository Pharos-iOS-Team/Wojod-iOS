// Copyright © 2026 Pharos Solutions. All rights reserved.

import Foundation
import Moya

enum HomeEndpoint {
    case loadSubjects(batchID: Int)
    case relatedCourses(CoursesRequestModel)
    case exploreMoreCourses(CoursesRequestModel)
    case searchCourses(SearchRequest)
    case loadAdvertisements
    case loadFilteredCourses(FilteredCoursesRequestModel)
}

extension HomeEndpoint: TargetType {
    var path: String {
        switch self {
        case let .loadSubjects(batchID):
            return "/batches/\(batchID)/subjects"
        case .relatedCourses:
            return "/related_courses"
        case .exploreMoreCourses:
            return "/courses"
        case .searchCourses:
            return "/courses/search"
        case .loadAdvertisements:
            return "/advertisements"
        case .loadFilteredCourses:
            return "/courses"
        }
    }

    var method: Moya.Method {
        return .get
    }

    var task: Task {
        switch self {
        case let .relatedCourses(requestModel), let .exploreMoreCourses(requestModel):
            return .queryParameters(requestModel)
        case let .searchCourses(requestModel):
            return .queryParameters(requestModel)
        case let .loadFilteredCourses(requestModel):
            return .queryParameters(requestModel)
        default:
            return .requestPlain
        }
    }
}
