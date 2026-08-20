// Copyright © 2026 Pharos Solutions. All rights reserved.

import Dependencies
import Foundation

protocol AdvertisementsRepositoryProtocol {
    func loadAdvertisements() async throws -> [Advertisement]
}

final class AdvertisementsRepository: AdvertisementsRepositoryProtocol {
    @Dependency(\.apiProvider)
    var apiProvider: ApiProvider

    func loadAdvertisements() async throws -> [Advertisement] {
        let advertisementResponse = try await apiProvider.request(.home(.loadAdvertisements), decodeTo:  ApiResponse<[Advertisement]>.self)
        return advertisementResponse.data
    }
}
