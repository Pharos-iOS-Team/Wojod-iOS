// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

class CreatePasswordModel {
    func createPassword(password: ForgetPasswordModel, completionHandler: @escaping (Swift.Result<Bool, Error>) -> Void) {
        ApiProvider.shared.request(.auth(.createPassword(password))) { result in
            switch result {
            case .success:
                completionHandler(.success(true))
            case let .failure(error):
                completionHandler(.failure(error))
            }
        }
    }
}
