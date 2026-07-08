// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

class AvatarModel {
    func fetchAvatars(completionHandler: @escaping (Swift.Result<ApiResponse<[Avatar]>, Error>) -> Void) {
        ApiProvider.shared.request(.profile(.getAvatars), decodeTo: ApiResponse<[Avatar]>.self, completion: completionHandler)
    }
}
