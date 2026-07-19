// Copyright © 2026 Pharos Solutions. All rights reserved.

import Dependencies
import Foundation

final class AvatarsViewModel {
    @Dependency(\.apiProvider)
    private var apiProvider: ApiProvider

    var avatars: [Avatar] = []
    var selectedIndexPath: IndexPath?

    private let imageSession = URLSession(configuration: .default)

    // MARK: - Intent Methods
    func saveAvatarSelection() {
        guard let indexPath = selectedIndexPath else { return }
        RegistrationStore.shared.update { state in
            state.avatar = self.avatars[safe: indexPath.item]
        }
    }

    func buildSignupRequest() -> UserSignupRequest {
        RegistrationStore.shared.buildSignupRequest()
    }

    // MARK: - Network

    func loadAvatars() async -> [Avatar] {
        do {
            let response = try await apiProvider.request(.profile(.getAvatars), decodeTo: ApiResponse<[Avatar]>.self)
            avatars = response.data
            return response.data
        } catch {
            return []
        }
    }

    func signUp(user: UserSignupRequest) async throws {
        _ = try await apiProvider.request(.registration(.signUp(user)))
    }

    // MARK: - Image Preloading

    func preloadAvatarImages() async -> [Int: Data] {
        let session = self.imageSession
        let avatars = self.avatars
        return await withTaskGroup(of: (Int, Data)?.self) { group in
            for (index, avatar) in avatars.enumerated() {
                guard
                    let path = avatar.thumbnailUrl,
                    !path.isEmpty,
                    let url = URL(string: AppEnvironment.baseURLString + path)
                else { continue }

                group.addTask {
                    guard let (data, _) = try? await session.data(from: url) else { return nil }
                    return (index, data)
                }
            }

            var results: [Int: Data] = [:]
            for await case let (index, data)? in group {
                results[index] = data
            }
            return results
        }
    }

    func cancelImageLoading() {
        imageSession.invalidateAndCancel()
    }
}
