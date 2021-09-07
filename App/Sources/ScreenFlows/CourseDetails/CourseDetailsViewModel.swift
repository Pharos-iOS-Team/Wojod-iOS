// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

class CourseDetailsViewModel {
    let model = CourseDetailsModel()

    func loadLessons(courseID: Int, completion: @escaping (LessonsModel) -> Void) {
        model.loadLessons(courseID: courseID) { result in
            switch result {
            case .success(let lessons as LessonsModel):
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

    func bookCourses(courseID: Int, completion: @escaping (BookingCourseResponseModel) -> Void) {
        model.bookCourse(courseID: courseID) { result in
            switch result {
            case .success(let bookingResponse as BookingCourseResponseModel):
                completion(bookingResponse)
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
        DispatchQueue.global().async { [unowned self] in
            model.loadMaterials(courseID: courseID) { result in
                switch result {
                case .success(let materials as Materials):
                    completion(materials)
                default:
                    return
                }
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

    func screenshotAlert(screenName: String, completion: @escaping (Bool) -> Void) {
        model.screenshotAlert(screenName: screenName) { isSentSuccessfully in
            completion(isSentSuccessfully)
        }
    }
}
