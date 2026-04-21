// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

class AvatarModel {
    func fetchAvatars(completionHandler: @escaping (Swift.Result<AvatarsModel, Error>) -> Void) {
        ApiProvider.shared.request(.profile(.getAvatars), decodeTo: AvatarsModel.self, completion: completionHandler)
    }
}
