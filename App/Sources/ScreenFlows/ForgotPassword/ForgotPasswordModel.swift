// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

class ForgotPasswordModel {
    func sendMobileNumber(
        mobileNumber: String,
        countryCode: String?,
        completionHandler: @escaping (Swift.Result<Bool, Error>) -> Void
    ) {
        let formatted = PhoneNumberValidator.formattedEgyptianPhone(mobileNumber, countryCode: countryCode ?? PhoneNumberValidator.egyptCountryCode)
        let requestModel = GetOTPRequestModel(mobileNumber: formatted, countryCode: countryCode)
        ApiProvider.shared.request(.auth(.sendMobileNumber(requestModel))) { result in
            switch result {
            case .success:
                completionHandler(.success(true))
            case let .failure(error):
                completionHandler(.failure(error))
            }
        }
    }
}
