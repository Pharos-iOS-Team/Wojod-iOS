// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation
import Moya

enum HomeTarget {
    case loadSubjects(batchID: Int)
    case relatedCourses(requestModel: CoursesRequestModel)
    case exploreMoreCourses(requestModel: CoursesRequestModel)
    case searchCourses(value: String)
    case loadAdvertisements
}

extension HomeTarget: TargetType {
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
        }
    }

    var method: Moya.Method {
        return .get
    }

    var task: Task {
        switch self {
        case .relatedCourses, .exploreMoreCourses, .searchCourses:
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        case .loadAdvertisements, .loadSubjects:
            return .requestPlain
        }
    }

    var parameters: [String: Any] {
        switch self {
        case let .relatedCourses(requestModel):
            let parameters: [String: Any?] = [
                "my_courses": requestModel.isMyCourses.description,
                "subject_id": requestModel.subjectID,
                "page": requestModel.page,
                "limit": requestModel.limit,
                "locale": Language.currentLanguage.rawValue
            ]
            return parameters.compactMapValues { $0 }
        case let .exploreMoreCourses(requestModel):
            return [
                "my_courses": requestModel.isMyCourses.description,
                "page": requestModel.page,
                "limit": requestModel.limit
            ].merged(with: sharedParameters)
        case let .searchCourses(value):
            return ["value": value].merged(with: sharedParameters)
        default:
            return [:]
        }
    }
}
