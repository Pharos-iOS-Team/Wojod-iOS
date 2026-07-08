// Copyright © 2026 Pharos Solutions. All rights reserved.

import Foundation

protocol AdvertisementsServicing {
    func loadAdvertisements() async throws -> Advertisements
}

final class AdvertisementsService: AdvertisementsServicing {
    private let apiProvider: ApiProvider

    init(apiProvider: ApiProvider = .shared) {
        self.apiProvider = apiProvider
    }

    func loadAdvertisements() async throws -> Advertisements {
        try await apiProvider.request(.home(.loadAdvertisements), decodeTo: Advertisements.self)
    }
}
