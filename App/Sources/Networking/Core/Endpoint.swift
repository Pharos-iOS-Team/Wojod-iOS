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
    private var innerTarget: any TargetType {
        guard let target: any TargetType = extractPayload() else {
            fatalError("Endpoint case has no TargetType payload: \(self)")
        }
        return target
    }

    var path: String { innerTarget.path }

    var method: Moya.Method { innerTarget.method }

    var task: Task { innerTarget.task }
}
