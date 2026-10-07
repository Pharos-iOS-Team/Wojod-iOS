// Copyright © 2026 Pharos Solutions. All rights reserved.

import Dependencies
import Foundation

protocol WhatsAppSupportRepositoryProtocol {
    func fetchWhatsAppSupportNumber() async throws -> String
}

final class WhatsAppSupportRepository: WhatsAppSupportRepositoryProtocol {
    @Dependency(\.apiProvider)
    var apiProvider: ApiProvider

    func fetchWhatsAppSupportNumber() async throws -> String {
        let loginOrganization = AppEnvironment.appName.loginOrganization
        let response = try await apiProvider.request(
            .home(.getWhatsAppSupportNumber(loginOrganization: loginOrganization)),
            decodeTo: ApiResponse<String>.self
        )
        return response.data
    }
}
