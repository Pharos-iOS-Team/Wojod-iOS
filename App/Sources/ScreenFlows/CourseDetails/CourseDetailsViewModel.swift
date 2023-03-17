// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

class CourseDetailsViewModel {
    private let model = CourseDetailsModel()

    func loadLessons(courseID: Int, completion: @escaping (LessonsModel) -> Void) {
        model.loadLessons(courseID: courseID) { result in
            switch result {
            case let .success(lessons as LessonsModel):
                completion(lessons)
            default:
                return
            }
        }
    }

    func loadReviews(courseID: Int, completion: @escaping (ReviewsModel) -> Void) {
        model.loadReviews(courseID: courseID) { result in
            switch result {
            case .success(let reviews as ReviewsModel):
                completion(reviews)
            default:
                return
            }
        }
    }

    func loadAttachmentsOfLesson(lessonID: Int, completion: @escaping (LessonAttachmentsModel) -> Void) {
        model.loadAttachmentsOfLesson(lessonID: lessonID) { result in
            switch result {
            case .success(let attachments as LessonAttachmentsModel):
                completion(attachments)
            default:
                return
            }
        }
    }

  func bookCourses(qrCode: String?, courseID: Int, completion: @escaping (BookingCourseResponseModel?, Error?) -> Void) {
      model.bookCourse(qrCode: qrCode, courseID: courseID) { result in
            switch result {
            case .success(let bookingResponse as BookingCourseResponseModel):
                completion(bookingResponse, nil)
            case .failure(let error as Error):
                completion(nil, error)
            default:
                return
            }
        }
    }

    func cancelBookingCourse(courseID: Int, completion: @escaping (Bool) -> Void) {
        model.cancelBookingCourse(courseID: courseID) { isCancellingBookingSuccessful in
            completion(isCancellingBookingSuccessful)
        }
    }

    func sendReview(courseID: Int, courseReview: CourseReview, completion: @escaping (Bool) -> Void) {
        model.sendReview(courseID: courseID, courseReview: courseReview) { isSentSuccessfully in
            completion(isSentSuccessfully)
        }
    }

    func loadMaterials(courseID: Int, completion: @escaping (Materials) -> Void) {
        model.loadMaterials(courseID: courseID) { result in
            switch result {
            case var .success(materials as Materials):
                materials.sort()
                completion(materials)
            default:
                return
            }
        }
    }

    func loadCourse(courseID: String, completion: @escaping (Course?) -> Void) {
        model.loadCourse(courseID: courseID) { result in
            switch result {
            case .success(let course as CourseDetailsResponse):
                completion(course.course)
            default:
                return
            }
        }
    }

    func fetchVideoDetails(videoId: String, completion: @escaping (EncryptedVideoResponse?) -> Void) {
        model.fetchVideo(videoId: videoId) { result in
            switch result {
            case .success(let encryptedViewResponse as EncryptedVideoResponse):
                completion(encryptedViewResponse)
            default:
                return
            }
        }
    }

    func updateVideo(videoId: String, updateObject: UpdateObject) {
        model.updateVideo(videoId: videoId, updateObject: updateObject) { result in
            switch result {
            case .failure(let error):
                print(error)
            default:
                return
            }
        }
    }
}
