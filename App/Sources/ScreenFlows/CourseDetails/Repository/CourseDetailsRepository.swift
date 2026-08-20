// Copyright © 2021 Pharos Solutions. All rights reserved.

import Dependencies
import Foundation

protocol CourseDetailsRepositoryProtocol {
    func loadCourse(courseID: String) async throws -> CourseDetailsResponse
    func loadLessons(courseID: Int) async throws -> [Lesson]
    func loadReviews(courseID: Int) async throws -> [Review]
    func loadAttachmentsOfLesson(lessonID: Int) async throws -> MaterialDomain
    func loadMaterials(courseID: Int) async throws -> MaterialDomain
    func bookCourse(courseID: Int, qrCode: String?) async throws -> BookingCourseResponseModel
    func cancelBookingCourse(courseID: Int) async throws
    func sendReview(courseID: Int, courseReview: CourseReview) async throws -> Bool
    func fetchVideoDetails(videoId: String) async throws -> EncryptedVideoResponse
    func updateVideo(videoId: String, updateObject: UpdateObject) async throws
    func fetchAllAttachments(for lessons: [Lesson]) async -> (attachments: [Int: MaterialDomain], contains: [Int: Bool])
}

final class CourseDetailsRepository: CourseDetailsRepositoryProtocol {
    @Dependency(\.apiProvider)
    private var apiProvider: ApiProvider

    func loadCourse(courseID: String) async throws -> CourseDetailsResponse {
        try await apiProvider.request(
            .courseDetails(.loadCourse(courseID: courseID)),
            decodeTo: CourseDetailsResponse.self
        )
    }

    func loadLessons(courseID: Int) async throws -> [Lesson] {
        let response = try await apiProvider.request(
            .courseDetails(.loadLessons(courseID: courseID)),
            decodeTo: ApiResponse<[Lesson]>.self
        )
        return response.data
    }

    func loadReviews(courseID: Int) async throws -> [Review] {
        let response = try await apiProvider.request(
            .courseDetails(.loadReviews(courseID: courseID)),
            decodeTo: ApiResponse<[Review]>.self
        )
        return response.data
    }

    func loadAttachmentsOfLesson(lessonID: Int) async throws -> MaterialDomain {
        let materials = try await apiProvider.request(
            .courseDetails(.loadAttachmentsOfLesson(lessonID: lessonID)),
            decodeTo: Materials.self
        )
        return materials.domainModel
    }

    func loadMaterials(courseID: Int) async throws -> MaterialDomain {
        var materials = try await apiProvider.request(
            .courseDetails(.loadMaterials(courseID: courseID)),
            decodeTo: Materials.self
        )
        materials.sort()
        return materials.domainModel
    }

    func bookCourse(courseID: Int, qrCode: String?) async throws -> BookingCourseResponseModel {
        try await apiProvider.request(
            .courseDetails(.bookCourse(
                courseID: courseID,
                requestModel: BookCourseRequestModel(code: qrCode)
            )),
            decodeTo: BookingCourseResponseModel.self
        )
    }

    func cancelBookingCourse(courseID: Int) async throws {
        _ = try await apiProvider.request(.courseDetails(.cancelBookingCourse(courseID: courseID)))
    }

    func sendReview(courseID: Int, courseReview: CourseReview) async throws -> Bool {
        _ = try await apiProvider.request(
            .courseDetails(.sendReview(courseID: courseID, courseReview: courseReview))
        )
        return true
    }

    func fetchVideoDetails(videoId: String) async throws -> EncryptedVideoResponse {
        try await apiProvider.request(
            .courseDetails(.fetchVideo(videoId: videoId)),
            decodeTo: EncryptedVideoResponse.self
        )
    }

    func updateVideo(videoId: String, updateObject: UpdateObject) async throws {
        _ = try await apiProvider.request(
            .courseDetails(.updateVideo(videoId: videoId, updateObject: updateObject))
        )
    }

    func fetchAllAttachments(for lessons: [Lesson]) async -> (attachments: [Int: MaterialDomain], contains: [Int: Bool]) {
        var attachments: [Int: MaterialDomain] = [:]
        var contains: [Int: Bool] = [:]
        await withTaskGroup(of: (Int, MaterialDomain?).self) { group in
            for (index, lesson) in lessons.enumerated() {
                group.addTask { [self] in
                    (index, try? await self.loadAttachmentsOfLesson(lessonID: lesson.id))
                }
            }
            for await (index, domain) in group {
                guard let domain else { continue }
                let isEmpty = domain.allMaterials.isEmpty
                attachments[index] = domain
                contains[index] = !isEmpty
            }
        }
        return (attachments, contains)
    }
}
