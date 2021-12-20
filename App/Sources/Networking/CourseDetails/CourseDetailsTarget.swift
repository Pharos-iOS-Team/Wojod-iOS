// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation
import Moya

struct UpdateObject: Codable {
    var updateId: Int
    var totalBuffered: Int
}

enum CourseDetailsTarget {
    case loadLessons(courseID: Int)
    case loadReviews(courseID: Int)
    case loadAttachmentsOfLesson(lessonID: Int)
    case bookCourse(courseID: Int)
    case cancelBookingCourse(courseID: Int)
    case sendReview(courseID: Int, courseReview: CourseReview)
    case loadMaterials(courseID: Int)
    case loadCourse(courseID: String)
    case fetchVideo(videoId: String)
    case updateVideo(videoId: String, updateObject: UpdateObject)
}

extension CourseDetailsTarget: TargetType {
    var path: String {
        switch self {
        case let .loadLessons(courseID):
            return "/courses/\(courseID)/lessons"
        case let .loadReviews(courseID):
            return "/courses/\(courseID)/reviews"
        case let .loadAttachmentsOfLesson(lessonID):
            return "/lessons/\(lessonID)"
        case let .bookCourse(courseID):
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
        case let .sendReview(_, courseReview):
            return .requestCustomJSONEncodable(courseReview, encoder: JSONEncoder.default)
        case let .updateVideo(_, updateObject):
            return .requestCustomJSONEncodable(updateObject, encoder: JSONEncoder.default)
        default:
            return .requestPlain
        }
    }
}
