// Copyright © 2026 Pharos Solutions. All rights reserved.

// swiftlint:disable all
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
        guard target is Endpoint else { return request }

        var request = request
        switch target as! Endpoint {
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
        guard target is Endpoint else { return }
        guard case let .success(response) = result else { return }

        switch target as! Endpoint {
        case .auth(.login), .auth(.verifyOtpFromLogin), .profile(.fetchProfile):
            saveAuthHeader(from: response)
        default:
            break
        }
    }

    private func saveAuthHeader(from response: Moya.Response) {
        let headers = response.response?.allHeaderFields as? [AnyHashable: String]
        guard
            let token = headers?[Header.accessToken.rawValue],
            let client = headers?[Header.client.rawValue],
            let uid = headers?[Header.uid.rawValue]
        else { return }

        User.shared.setLoggedIn(token: token, client: client, uid: uid)
    }
}
