// Copyright © 2026 Pharos Solutions. All rights reserved.

import Foundation
import Moya

enum CourseDetailsEndpoint {
    case loadLessons(courseID: Int)
    case loadReviews(courseID: Int)
    case loadAttachmentsOfLesson(lessonID: Int)
    case bookCourse(courseID: Int, requestModel: BookCourseRequestModel)
    case cancelBookingCourse(courseID: Int)
    case sendReview(courseID: Int, courseReview: CourseReview)
    case loadMaterials(courseID: Int)
    case loadCourse(courseID: String)
    case fetchVideo(videoId: String)
    case updateVideo(videoId: String, updateObject: UpdateObject)
}

extension CourseDetailsEndpoint: TargetType {
    var path: String {
        switch self {
        case let .loadLessons(courseID):
            return "/courses/\(courseID)/lessons"
        case let .loadReviews(courseID):
            return "/courses/\(courseID)/reviews"
        case let .loadAttachmentsOfLesson(lessonID):
            return "/lessons/\(lessonID)"
        case let .bookCourse(courseID, _):
            return "/courses/\(courseID)/reservations"
        case let .cancelBookingCourse(courseID):
            return "/courses/\(courseID)/reservations"
        case let .sendReview(courseID, _):
            return "/courses/\(courseID)/reviews"
        case let .loadMaterials(courseID):
            return "/courses/\(courseID)/materials"
        case let .loadCourse(courseID):
            return "courses/\(courseID)"
        case let .fetchVideo(videoId):
            return "videos/\(videoId)"
        case let .updateVideo(videoId, _):
            return "videos/\(videoId)/seconds_viewed"
        }
    }

    var method: Moya.Method {
        switch self {
        case .bookCourse, .sendReview:
            return .post
        case .cancelBookingCourse:
            return .delete
        case .updateVideo:
            return .put
        default:
            return .get
        }
    }

    var task: Task {
        switch self {
        case let .bookCourse(_, requestModel):
            do {
                return .requestParameters(
                    parameters: try requestModel.toDictionary(encoder: .default),
                    encoding: URLEncoding.queryString
                )
            } catch {
                return .requestPlain
            }

        case let .sendReview(_, courseReview):
            do {
                return .requestParameters(
                    parameters: try courseReview.toDictionary(encoder: .default),
                    encoding: JSONEncoding.default
                )
            } catch {
                return .requestPlain
            }

        case let .updateVideo(_, updateObject):
            do {
                return .requestParameters(
                    parameters: try updateObject.toDictionary(encoder: .default),
                    encoding: JSONEncoding.default
                )
            } catch {
                return .requestPlain
            }

        default:
            return .requestPlain
        }
    }
}
