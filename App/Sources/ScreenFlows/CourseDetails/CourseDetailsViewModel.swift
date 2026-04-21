// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation
import SwiftyUserDefaults

class CourseDetailsViewModel {
    private let model = CourseDetailsModel()

    func loadLessons(courseID: Int, completion: @escaping (LessonsModel) -> Void) {
        model.loadLessons(courseID: courseID) { result in
            switch result {
            case .success(let lessons):
                completion(lessons)
            case .failure:
                break
            }
        }
    }

    func loadReviews(courseID: Int, completion: @escaping (ReviewsModel) -> Void) {
        model.loadReviews(courseID: courseID) { result in
            switch result {
            case .success(let reviews):
                completion(reviews)
            case .failure:
                break
            }
        }
    }

    func loadAttachmentsOfLesson(lessonID: Int, completion: @escaping (LessonAttachmentsModel) -> Void) {
        model.loadAttachmentsOfLesson(lessonID: lessonID) { result in
            switch result {
            case .success(let attachments):
                completion(attachments)
            case .failure:
                break
            }
        }
    }

    func bookCourses(qrCode: String?, courseID: Int, completion: @escaping (BookingCourseResponseModel?, Error?) -> Void) {
        model.bookCourse(qrCode: qrCode, courseID: courseID) { result in
            switch result {
            case .success(let bookingResponse):
                completion(bookingResponse, nil)
            case .failure(let error):
                completion(nil, error)
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
            case .success(var materials):
                materials.sort()
                completion(materials)
            case .failure:
                break
            }
        }
    }

    func loadCourse(courseID: String, completion: @escaping (CourseDetailsResponse) -> Void) {
        model.loadCourse(courseID: courseID) { result in
            switch result {
            case .success(let course):
                completion(course)
            case .failure:
                break
            }
        }
    }

    func fetchVideoDetails(videoId: String, completion: @escaping (EncryptedVideoResponse?) -> Void) {
        model.fetchVideo(videoId: videoId) { result in
            switch result {
            case .success(let encryptedViewResponse):
                completion(encryptedViewResponse)
            case .failure:
                completion(nil)
            }
        }
    }

    func updateVideo(videoId: String, updateObject: UpdateObject) {
        model.updateVideo(videoId: videoId, updateObject: updateObject) { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success:
                break
            }
        }
    }

    func isGuestModeEnabled() -> Bool {
        return Defaults[\.isGuestModeEnabled]
    }

    func logout() {
        User.shared.setLoggedOut()
        ScreensFlowConfigurationAppDelegate.shared.navigateToMainScreen()
        Defaults[\.isGuestModeEnabled] = false
    }
}
