// Copyright © 2026 Pharos Solutions. All rights reserved.

import Foundation

protocol AdvertisementsServicing {
    func loadAdvertisements(completion: @escaping (Result<Advertisements, Error>) -> Void)
}

final class AdvertisementsService: AdvertisementsServicing {
    private let apiProvider: ApiProvider

    init(apiProvider: ApiProvider = .shared) {
        self.apiProvider = apiProvider
    }

    func loadAdvertisements(completion: @escaping (Result<Advertisements, Error>) -> Void) {
        apiProvider.request(.home(.loadAdvertisements), decodeTo: Advertisements.self) { result in
            completion(result)
        }
    }
}
