// Copyright © 2021 Pharos Solutions. All rights reserved.

import Dependencies
import Foundation

class FiltersViewModel {
    @Dependency(\.apiProvider)
    var apiProvider: ApiProvider

    internal func loadAcademicTypes(for academicLevel: AcademicLevel) async -> [KeyValue]? {
        let requestModel = AcademicRequestModel(educationLevel: academicLevel.rawValue)
        do {
            let response = try await apiProvider.request(
                .registration(.academicTypes(requestModel)),
                decodeTo: ApiResponse<[KeyValue]>.self
            )
            return response.data
        } catch {
            return nil
        }
    }

    internal func loadAcademicDivisions(for academicLevel: AcademicLevel, in educationType: Int) async -> [Division]? {
        let requestModel = AcademicRequestModel(
            educationLevel: academicLevel.rawValue,
            educationType: academicLevel == .schoolStudent ? educationType : nil,
            loginOrganization: academicLevel == .schoolStudent ? nil : AppEnvironment.appName.loginOrganization
        )
        do {
            let response = try await apiProvider.request(
                .registration(.academicDivisions(requestModel)),
                decodeTo: ApiResponse<[Division]>.self
            )
            return response.data
        } catch {
            return nil
        }
    }

    internal func loadBatches(for divisionIndex: Int) async -> [KeyValue]? {
        do {
            let response = try await apiProvider.request(
                .registration(.batches(divisionID: divisionIndex)),
                decodeTo: ApiResponse<[KeyValue]>.self
            )
            return response.data
        } catch {
            return nil
        }
    }

    internal func loadSubjects(forYear yearID: Int) async -> [Subject]? {
        do {
            let subjectsResponse = try await apiProvider.request(
                .home(.loadSubjects(batchID: yearID)),
                decodeTo: ApiResponse<[Subject]>.self
            )
            return subjectsResponse.data
        } catch {
            return nil
        }
    }

    func loadSpecializations(for divisionIndex: Int) async -> [KeyValue]? {
        do {
            let response = try await apiProvider.request(
                .registration(.specializations(divisionID: divisionIndex)),
                decodeTo: ApiResponse<[KeyValue]>.self
            )
            return response.data
        } catch {
            return nil
        }
    }

    func loadFilteredCourses(subjectID: Int?, batchID: Int, specializationID: Int?) async -> CoursesResponse? {
        let requestModel = FilteredCoursesRequestModel(
            isMyCourses: false,
            subjectID: subjectID,
            batchID: batchID,
            specializationID: specializationID
        )
        do {
            return try await apiProvider.request(
                .home(.loadFilteredCourses(requestModel)),
                decodeTo: CoursesResponse.self
            )
        } catch {
            return nil
        }
    }
}
