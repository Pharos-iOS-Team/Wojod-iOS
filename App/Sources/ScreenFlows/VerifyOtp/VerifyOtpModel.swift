// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

class VerifyOtpModel {
    func verifyOtp(otp: OtpVerification, completionHandler: @escaping (Swift.Result<Bool, Error>) -> Void) {
        ApiProvider.shared.request(.auth(.verifyOtp(otp))) { result in
            switch result {
            case .success:
                completionHandler(.success(true))
            case let .failure(error):
                completionHandler(.failure(error))
            }
        }
    }

    func verifyOtpFromLogin(otp: OtpVerification, completionHandler: @escaping (Swift.Result<LoginApiResponseModel, Error>) -> Void) {
        ApiProvider.shared.request(.auth(.verifyOtpFromLogin(otp)), decodeTo: LoginApiResponseModel.self, completion: completionHandler)
    }
}
