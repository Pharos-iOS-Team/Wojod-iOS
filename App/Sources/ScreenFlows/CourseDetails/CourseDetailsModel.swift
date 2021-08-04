// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

class CourseDetailsModel: ModelDecodable {
    let apiClient = CourseDetailsApiClient()

    func loadLessons(courseID: Int, completion: @escaping (Result) -> Void) {
        apiClient.loadLessons(courseID: courseID) { response, error in
            if let response = response {
                if response.statusCode < 300 {
                    self.decode(modelType: LessonsModel.self, from: response) { result in
                        completion(result)
                    }
                } else {
                    self.decodeError(response: response, completionHandler: completion)
                }
            } else if let error = error {
                completion(.failure(WJError(type: .parsingError, message: error.localizedDescription)))
            }
        }
    }

    func loadReviews(courseID: Int, completion: @escaping (Result) -> Void) {
        apiClient.loadReviews(courseID: courseID) { response, error in
            if let response = response {
                if response.statusCode < 300 {
                    self.decode(modelType: ReviewsModel.self, from: response) { result in
                        completion(result)
                    }
                } else {
                    self.decodeError(response: response, completionHandler: completion)
                }
            } else if let error = error {
                completion(.failure(WJError(type: .parsingError, message: error.localizedDescription)))
            }
        }
    }

    func loadAttachmentsOfLesson(lessonID: Int, completion: @escaping (Result) -> Void) {
        apiClient.loadAttachmentsOfLesson(lessonID: lessonID) { response, error in
            if let response = response {
                if response.statusCode < 300 {
                    self.decode(modelType: LessonAttachmentsModel.self, from: response) { result in
                        completion(result)
                    }
                } else {
                    self.decodeError(response: response, completionHandler: completion)
                }
            } else if let error = error {
                completion(.failure(WJError(type: .parsingError, message: error.localizedDescription)))
            }
        }
    }

    func bookCourse(courseID: Int, completion: @escaping (Result) -> Void) {
        apiClient.bookCourse(courseID: courseID) { response, error in
            if let response = response {
                if response.statusCode < 300 {
                    self.decode(modelType: BookingCourseResponseModel.self, from: response) { result in
                        completion(result)
                    }
                } else {
                    self.decodeError(response: response, completionHandler: completion)
                }
            } else if let error = error {
                completion(.failure(WJError(type: .parsingError, message: error.localizedDescription)))
            }
        }
    }

    func cancelBookingCourse(courseID: Int, completion: @escaping (Bool) -> Void) {
        apiClient.cancelBookingCourse(courseID: courseID) { response, _ in
            if let response = response {
                if response.statusCode < 300 {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    }

    func sendReview(courseID: Int, courseReview: CourseReview, completion: @escaping (Bool) -> Void) {
        apiClient.sendReview(courseID: courseID, courseReview: courseReview) { response, _ in
            if let response = response {
                if response.statusCode < 300 {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    }

    func loadMaterials(courseID: Int, completion: @escaping (Result) -> Void) {
        DispatchQueue.global().async {
            self.apiClient.loadMaterials(courseID: courseID) { response, error in
                if let response = response {
                    if response.statusCode < 300 {
                        self.decode(modelType: Materials.self, from: response) { result in
                            completion(result)
                        }
                    } else {
                        self.decodeError(response: response, completionHandler: completion)
                    }
                } else if let error = error {
                    completion(.failure(WJError(type: .parsingError, message: error.localizedDescription)))
                }
            }
        }
    }

    func loadCourse(courseID: String, completion: @escaping (Result) -> Void) {
        apiClient.loadCourse(courseID: courseID) { response, error in
            if let response = response {
                if response.statusCode < 300 {
                    self.decode(modelType: CourseDetailsResponse.self, from: response) { result in
                        completion(result)
                    }
                } else {
                    self.decodeError(response: response, completionHandler: completion)
                }
            } else if let error = error {
                completion(.failure(WJError(type: .parsingError, message: error.localizedDescription)))
            }
        }
    }
}
