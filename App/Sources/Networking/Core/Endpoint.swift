// Copyright © 2026 Pharos Solutions. All rights reserved.

import Foundation
import Moya

enum Endpoint {
    case auth(AuthEndpoint)
    case home(HomeEndpoint)
    case courseDetails(CourseDetailsEndpoint)
    case profile(ProfileEndpoint)
    case chat(ChatEndpoint)
    case notifications(NotificationsEndpoint)
    case academicInfo(AcademicInfoEndpoint)
    case organizationsList(OrganizationsListEndpoint)
    case registration(RegistrationEndpoint)
    case assessments(AssessmentsEndpoint)
}

extension Endpoint: TargetType {
    var path: String {
        switch self {
        case let .auth(endpoint):
            return endpoint.path
        case let .home(endpoint):
            return endpoint.path
        case let .courseDetails(endpoint):
            return endpoint.path
        case let .profile(endpoint):
            return endpoint.path
        case let .chat(endpoint):
            return endpoint.path
        case let .notifications(endpoint):
            return endpoint.path
        case let .academicInfo(endpoint):
            return endpoint.path
        case let .organizationsList(endpoint):
            return endpoint.path
        case let .registration(endpoint):
            return endpoint.path
        case let .assessments(endpoint):
            return endpoint.path
        }
    }

    var method: Moya.Method {
        switch self {
        case let .auth(endpoint):
            return endpoint.method
        case let .home(endpoint):
            return endpoint.method
        case let .courseDetails(endpoint):
            return endpoint.method
        case let .profile(endpoint):
            return endpoint.method
        case let .chat(endpoint):
            return endpoint.method
        case let .notifications(endpoint):
            return endpoint.method
        case let .academicInfo(endpoint):
            return endpoint.method
        case let .organizationsList(endpoint):
            return endpoint.method
        case let .registration(endpoint):
            return endpoint.method
        case let .assessments(endpoint):
            return endpoint.method
        }
    }

    var task: Task {
        switch self {
        case let .auth(endpoint):
            return endpoint.task
        case let .home(endpoint):
            return endpoint.task
        case let .courseDetails(endpoint):
            return endpoint.task
        case let .profile(endpoint):
            return endpoint.task
        case let .chat(endpoint):
            return endpoint.task
        case let .notifications(endpoint):
            return endpoint.task
        case let .academicInfo(endpoint):
            return endpoint.task
        case let .organizationsList(endpoint):
            return endpoint.task
        case let .registration(endpoint):
            return endpoint.task
        case let .assessments(endpoint):
            return endpoint.task
        }
    }
}
