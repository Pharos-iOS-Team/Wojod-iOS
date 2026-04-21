// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

class LoginModel {
    func login(mobileNumber: String, password: String, completionHandler: @escaping (Swift.Result<LoginApiResponseModel, Error>) -> Void) {
        let loginRequestModel = LoginRequestModel(mobileNumber: mobileNumber, password: password)
        ApiProvider.shared.request(.auth(.login(loginRequestModel)), decodeTo: LoginApiResponseModel.self, completion: completionHandler)
    }

    func guestMode(completionHandler: @escaping (Swift.Result<VersionResponse, Error>) -> Void) {
        let requestModel = GuestModeRequestModel(appName: AppEnvironment.appName.guestModeKey)
        ApiProvider.shared.request(.auth(.guestMode(requestModel)), decodeTo: VersionResponse.self, completion: completionHandler)
    }

    func loadGuestModelUserData() -> LoginApiResponseModel? {
        guard let url = Bundle.main.url(forResource: "LoginResponse", withExtension: "json") else { return nil }

        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder.default.decode(LoginApiResponseModel.self, from: data)
        } catch {
            return nil
        }
    }
}
