// Copyright © 2026 Pharos Solutions. All rights reserved.

import Foundation
import Moya

enum Endpoint: TargetType {
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

extension Endpoint: PayloadExtractable {
    var resolvedTarget: (any TargetType)? {
        extractPayload()
    }

    var path: String { resolvedTarget?.path ?? "" }

    var method: Moya.Method { resolvedTarget?.method ?? .get }

    var task: Task { resolvedTarget?.task ?? .requestPlain }
}
