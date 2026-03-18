// Copyright © 2021 Pharos Solutions. All rights reserved.

import Alamofire
import Foundation
import Moya
import SwiftyUserDefaults

internal class NetworkProvider {
    internal static var shared = NetworkProvider()

    private let provider = MoyaProvider<RegistrationService>( [NetworkLoggerPlugin(configuration: .init(logOptions: [.formatRequestAscURL, .verbose]))]
    )

    internal func request(
        target: RegistrationService,
        completion: @escaping (Response?, NetworkError?) -> Void
    ) {
        provider.request(target) { result in
            switch result {
            case .success(let response):
                if let error = self.decodeErrorResponse(from: response.data), error.message != nil {
                    completion(nil, error)
                } else {
                    completion(response, nil)
                }
            case .failure(let error):
                let responseError = NetworkError(error: error)
                completion(nil, responseError)
            }
        }
    }

    internal func request<T: Decodable>(
        target: RegistrationService,
        type: T.Type,
        completion: @escaping ((T?, NetworkError?) -> Void)
    ) {
        provider.request(target) { result in
            switch result {
            case .success(let response):
                if let error = self.decodeErrorResponse(from: response.data), error.message != nil {
                    completion(nil, error)
                } else {
                    do {
                        try self.decodeSuccessResponse(
                            type,
                            response.data,
                            completion
                        )
                    } catch {
                        let decodingError = NetworkError(error: error)
                        completion(nil, decodingError)
                    }
                }
            case .failure(let error):
                let responseError = NetworkError(error: error)
                completion(nil, responseError)
            }
        }
    }

    private func decodeSuccessResponse<T: Decodable>(
        _ type: T.Type,
        _ responseData: Data,
        _ completion: @escaping ((T?, NetworkError?) -> Void)
    ) throws {
        let decodedResponse = try JSONDecoder.default.decode(
            T.self,
            from: responseData
        )
        completion(decodedResponse, nil)
    }

    private func decodeErrorResponse(from data: Data) -> NetworkError? {
        do {
            let errorResponse = try JSONDecoder().decode(
                NetworkError.self,
                from: data
            )
            return errorResponse
        } catch {
            return nil
        }
    }
}
