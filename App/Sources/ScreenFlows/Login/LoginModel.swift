// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation
import Moya

class LoginModel {
    func login(mobileNumber: String, password: String, completionHandler: @escaping (Swift.Result<ApiResponse<UserModel>, Error>) -> Void) {
        let loginRequestModel = LoginRequestModel(mobileNumber: mobileNumber, password: password)
        ApiProvider.shared.request(.auth(.login(loginRequestModel)), decodeTo: ApiResponse<UserModel>.self, completion: completionHandler)
    }

    func verifyPhone(mobileNumber: String, completionHandler: @escaping (Swift.Result<VerifyPhoneResponse, Error>) -> Void) {
        let requestModel = VerifyPhoneRequestModel(phoneNumber: mobileNumber)
        ApiProvider.shared.request(.auth(.verifyPhone(requestModel)), decodeTo: VerifyPhoneResponse.self, completion: completionHandler)
    }

    func resendOtpForLogin(mobileNumber: String, completionHandler: @escaping (Swift.Result<Moya.Response, Error>) -> Void) {
        ApiProvider.shared.request(.auth(.resendOtpForLogin(mobileNumber: mobileNumber)), completion: completionHandler)
    }

    func guestMode(completionHandler: @escaping (Swift.Result<VersionResponse, Error>) -> Void) {
        let requestModel = GuestModeRequestModel(appName: AppEnvironment.appName.guestModeKey)
        ApiProvider.shared.request(.auth(.guestMode(requestModel)), decodeTo: VersionResponse.self, completion: completionHandler)
    }

    func loadGuestModelUserData() -> UserModel? {
        guard let url = Bundle.main.url(forResource: "LoginResponse", withExtension: "json") else { return nil }

        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder.default.decode(ApiResponse<UserModel>.self, from: data).data
        } catch {
            return nil
        }
    }
}
