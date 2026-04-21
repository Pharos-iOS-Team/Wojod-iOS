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
            do {
                return .requestParameters(
                    parameters: try requestModel.toDictionary(encoder: .default),
                    encoding: URLEncoding.queryString
                )
            } catch {
                return .requestPlain
            }

        case let .searchCourses(requestModel):
            do {
                return .requestParameters(
                    parameters: try requestModel.toDictionary(encoder: .default),
                    encoding: URLEncoding.queryString
                )
            } catch {
                return .requestPlain
            }

        case let .loadFilteredCourses(requestModel):
            do {
                return .requestParameters(
                    parameters: try requestModel.toDictionary(encoder: .default),
                    encoding: URLEncoding.queryString
                )
            } catch {
                return .requestPlain
            }

        default:
            return .requestPlain
        }
    }
}
