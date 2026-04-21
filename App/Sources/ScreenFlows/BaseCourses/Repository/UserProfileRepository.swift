// Copyright © 2026 Pharos Solutions. All rights reserved.

import Dependencies
import Foundation

protocol UserProfileRepositoryProtocol {
    func fetchUserProfile() async throws -> UserModel
}

final class UserProfileRepository: UserProfileRepositoryProtocol {
    @Dependency(\.apiProvider)
    var apiProvider: ApiProvider

    func fetchUserProfile() async throws -> UserModel {
        guard let userId = User.shared.id, userId > 0 else {
            throw ApiError.unauthorized(error: L10n.Global.Alerts.somethingWentWrong)
        }
        return try await apiProvider.request(
            .profile(.fetchProfile(.init(id: String(userId)))),
            decodeTo: ApiResponse<UserModel>.self
        ).data
    }
}
