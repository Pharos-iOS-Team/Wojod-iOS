// Copyright © 2021 Pharos Solutions. All rights reserved.

import Alamofire
import Foundation
import Moya

protocol ModelDecodable {
    func decode<Model: Decodable>(modelType: Model.Type, from response: Response, completionHandler: @escaping (Result) -> Void)
    func decodeError(response: Response, completionHandler: @escaping (Result) -> Void)
    func handleMoyaError(error: MoyaError, completionHandler: @escaping (Result) -> Void)
}

extension ModelDecodable {
    func decode<Model: Decodable>(modelType: Model.Type, from response: Response, completionHandler: @escaping (Result) -> Void) {
        let decoded = decode(modelType: modelType, from: response.data)
        if let decodedData = decoded.data {
            completionHandler(.success(decodedData))
        } else if let error = decoded.catchedError {
            completionHandler(.failure(WJError(type: .parsingError, message: error)))
        }
    }

    func decodeError(response: Response, completionHandler: @escaping (Result) -> Void) {
        let error = decode(modelType: ErrorModel.self, from: response.data)
        if let error = error.data {
            let customError = WJError(
                type: .serverSideError(statusCode: HTTPStatusCode(rawValue: response.statusCode)),
                message: error.errors?.commaSeparatedString ?? ""
            )
            completionHandler(.failure(customError))
        } else if let error = error.catchedError {
            completionHandler(.failure(WJError(type: .parsingError, message: error)))
        }
    }

    func cacheAccessToken(headers: [AnyHashable: Any]?) {
        guard let token = headers?["access-token"] as? String,
              let client = headers?["client"] as? String,
              let uid = headers?["uid"] as? String
        else { return }
        User.shared.setLoggedIn(token: token, client: client, uid: uid)
    }

    func handleMoyaError(error: MoyaError, completionHandler: @escaping (Result) -> Void) {
        if let alamofireError = error.errorUserInfo["NSUnderlyingError"] as? Alamofire.AFError,
        let underlyingError = alamofireError.underlyingError as NSError?,
        [NSURLErrorNotConnectedToInternet, NSURLErrorDataNotAllowed].contains(underlyingError.code) {
            completionHandler(.failure(WJError(type: .parsingError, message: L10n.Global.Alerts.noInternetConnection)))
        } else {
            completionHandler(.failure(WJError(type: .parsingError, message: L10n.Global.Alerts.somethingWentWrong)))
        }
    }

    private func decode<T: Decodable>(modelType: T.Type, from data: Data) -> (data: T?, catchedError: String?) {
        do {
            let decodedData = try JSONDecoder.default.decode(modelType, from: data)
            return (decodedData, nil)
        } catch (let catcedError) {
            print(catcedError)
            AnalyticsEventLogger.log(error: "Decoding error in module \(modelType). Error is \(catcedError.localizedDescription)")
            return (nil, L10n.Global.Alerts.dataPreparationError)
        }
    }
}
