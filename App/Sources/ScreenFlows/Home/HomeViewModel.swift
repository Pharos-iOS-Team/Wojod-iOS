// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

class HomeViewModel {
    let model = HomeModel()

    var errorHandler: ((WJError) -> Void)?
    var successHandler: ((StudentModel) -> Void)?
    var showIndicator: (() -> Void)?

    func getUserProfile(id: Int) {
        model.getUserProfile(id: id) { result in
            switch result {
            case .success(let user as StudentModel):
                self.setUserData(user)
                self.successHandler?(user)
            case .failure(let error):
                self.errorHandler?(error)
            default:
                return
            }
        }
    }

    private func setUserData(_ user: StudentModel) {
        User.shared.setUserData(user: nil, student: user) 
    }
}
