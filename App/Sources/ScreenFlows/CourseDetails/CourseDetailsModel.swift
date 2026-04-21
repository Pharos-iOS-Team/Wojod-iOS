// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

class CourseDetailsModel {
    func loadLessons(courseID: Int, completion: @escaping (Swift.Result<LessonsModel, Error>) -> Void) {
        ApiProvider.shared.request(.courseDetails(.loadLessons(courseID: courseID)), decodeTo: LessonsModel.self, completion: completion)
    }

    func loadReviews(courseID: Int, completion: @escaping (Swift.Result<ReviewsModel, Error>) -> Void) {
        ApiProvider.shared.request(.courseDetails(.loadReviews(courseID: courseID)), decodeTo: ReviewsModel.self, completion: completion)
    }

    func loadAttachmentsOfLesson(lessonID: Int, completion: @escaping (Swift.Result<LessonAttachmentsModel, Error>) -> Void) {
        ApiProvider.shared.request(.courseDetails(.loadAttachmentsOfLesson(lessonID: lessonID)), decodeTo: LessonAttachmentsModel.self, completion: completion)
    }

    func bookCourse(qrCode: String?, courseID: Int, completion: @escaping (Swift.Result<BookingCourseResponseModel, Error>) -> Void) {
        let requestModel = BookCourseRequestModel(code: qrCode)
        ApiProvider.shared.request(.courseDetails(.bookCourse(courseID: courseID, requestModel: requestModel)), decodeTo: BookingCourseResponseModel.self, completion: completion)
    }

    func cancelBookingCourse(courseID: Int, completion: @escaping (Bool) -> Void) {
        ApiProvider.shared.request(.courseDetails(.cancelBookingCourse(courseID: courseID))) { result in
            switch result {
            case .success:
                completion(true)
            case .failure:
                completion(false)
            }
        }
    }

    func sendReview(courseID: Int, courseReview: CourseReview, completion: @escaping (Bool) -> Void) {
        ApiProvider.shared.request(.courseDetails(.sendReview(courseID: courseID, courseReview: courseReview))) { result in
            switch result {
            case .success:
                completion(true)
            case .failure:
                completion(false)
            }
        }
    }

    func loadMaterials(courseID: Int, completion: @escaping (Swift.Result<Materials, Error>) -> Void) {
        ApiProvider.shared.request(.courseDetails(.loadMaterials(courseID: courseID)), decodeTo: Materials.self, completion: completion)
    }

    func loadCourse(courseID: String, completion: @escaping (Swift.Result<CourseDetailsResponse, Error>) -> Void) {
        ApiProvider.shared.request(.courseDetails(.loadCourse(courseID: courseID)), decodeTo: CourseDetailsResponse.self, completion: completion)
    }

    func fetchVideo(videoId: String, completion: @escaping (Swift.Result<EncryptedVideoResponse, Error>) -> Void) {
        ApiProvider.shared.request(.courseDetails(.fetchVideo(videoId: videoId)), decodeTo: EncryptedVideoResponse.self, completion: completion)
    }

    func updateVideo(videoId: String, updateObject: UpdateObject, completion: @escaping (Swift.Result<Void, Error>) -> Void) {
        ApiProvider.shared.request(.courseDetails(.updateVideo(videoId: videoId, updateObject: updateObject))) { result in
            switch result {
            case .success:
                completion(.success(()))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}
