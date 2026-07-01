// Copyright © 2026 Pharos Solutions. All rights reserved.

import Foundation
import Moya
import SwiftyUserDefaults

final class AuthPlugin: PluginType {
    enum Header: String {
        case accessToken = "access-token"
        case client
        case uid
    }

    // MARK: - Request
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        guard let endpoint = target as? Endpoint else { return request }

        var request = request
        switch endpoint {
        case .auth(.login), .auth(.guestMode), .auth(.sendMobileNumber), .auth(.verifyOtp), .auth(.verifyOtpFromLogin):
            return request
        default:
            setAuthHeader(for: &request)
            return request
        }
    }

    private func setAuthHeader(for request: inout URLRequest) {
        let accessToken = KeychainHandler.shared.userToken ?? ""
        let client = Defaults[\.clientKey] ?? ""
        let uid = Defaults[\.uidKey] ?? ""

        request.setValue(accessToken, forHTTPHeaderField: Header.accessToken.rawValue)
        request.setValue(client, forHTTPHeaderField: Header.client.rawValue)
        request.setValue(uid, forHTTPHeaderField: Header.uid.rawValue)
    }

    // MARK: - Response

    func didReceive(_ result: Swift.Result<Moya.Response, MoyaError>, target: TargetType) {
        guard let endpoint = target as? Endpoint, case let .success(response) = result else { return }
        switch endpoint {
        case .auth(.login), .auth(.verifyOtpFromLogin), .profile(.fetchProfile):
            saveAuthHeader(from: response)
        default:
            break
        }
    }

    private func saveAuthHeader(from response: Moya.Response) {
        guard let httpResponse = response.response else { return }
        guard
            let token = httpResponse.value(forHTTPHeaderField: Header.accessToken.rawValue),
            let client = httpResponse.value(forHTTPHeaderField: Header.client.rawValue),
            let uid = httpResponse.value(forHTTPHeaderField: Header.uid.rawValue)
        else { return }

        User.shared.setLoggedIn(token: token, client: client, uid: uid)
    }
}
