// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation
import Moya

class CourseDetailsApiClient {
    let courseDetailsProvider = MoyaProvider<CourseDetailsTarget>()

    func loadLessons(courseID: Int, completion: @escaping (Response?, MoyaError?) -> Void) {
        courseDetailsProvider.request(.loadLessons(courseID: courseID)) { result in
            switch result {
            case .success(let response):
                completion(response, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }

    func loadReviews(courseID: Int, completion: @escaping (Response?, MoyaError?) -> Void) {
        courseDetailsProvider.request(.loadReviews(courseID: courseID)) { result in
            switch result {
            case .success(let response):
                completion(response, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }

    func loadAttachmentsOfLesson(lessonID: Int, completion: @escaping (Response?, MoyaError?) -> Void) {
        courseDetailsProvider.request(.loadAttachmentsOfLesson(lessonID: lessonID)) { result in
            switch result {
            case .success(let response):
                completion(response, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }

    func bookCourse(courseID: Int, completion: @escaping (Response?, MoyaError?) -> Void) {
        courseDetailsProvider.request(.bookCourse(courseID: courseID)) { result in
            switch result {
            case .success(let response):
                completion(response, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }

    func cancelBookingCourse(courseID: Int, completion: @escaping (Response?, MoyaError?) -> Void) {
        courseDetailsProvider.request(.cancelBookingCourse(courseID: courseID)) { result in
            switch result {
            case .success(let response):
                completion(response, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }

    func sendReview(courseID: Int, courseReview: CourseReview, completion: @escaping (Response?, MoyaError?) -> Void) {
        courseDetailsProvider.request(.sendReview(courseID: courseID, courseReview: courseReview)) { result in
            switch result {
            case .success(let response):
                completion(response, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
}
