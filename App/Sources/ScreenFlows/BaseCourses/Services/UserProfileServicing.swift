// Copyright © 2026 Pharos Solutions. All rights reserved.

import Foundation

protocol UserProfileServicing {
    func fetchUserProfile() async throws -> StudentModel
}

final class UserProfileService: UserProfileServicing {
    private let apiProvider: ApiProvider

    init(apiProvider: ApiProvider = .shared) {
        self.apiProvider = apiProvider
    }

    func fetchUserProfile() async throws -> StudentModel {
        let userId = String(User.shared.id ?? 0)
        return try await apiProvider.request(
            .profile(.fetchProfile(.init(id: userId))),
            decodeTo: StudentModel.self
        )
    }
}
