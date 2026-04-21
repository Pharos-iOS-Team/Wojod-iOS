// Copyright © 2026 Pharos Solutions. All rights reserved.

import Foundation

protocol UserProfileServicing {
    func fetchUserProfile(completion: @escaping (Result<StudentModel, Error>) -> Void)
}

final class UserProfileService: UserProfileServicing {
    private let apiProvider: ApiProvider

    init(apiProvider: ApiProvider = .shared) {
        self.apiProvider = apiProvider
    }

    func fetchUserProfile(completion: @escaping (Result<StudentModel, Error>) -> Void) {
        let userId = String(User.shared.id ?? 0)
        apiProvider.request(
            .profile(.fetchProfile(.init(id: userId))),
            decodeTo: StudentModel.self
        ) { result in
            completion(result)
        }
    }
}
