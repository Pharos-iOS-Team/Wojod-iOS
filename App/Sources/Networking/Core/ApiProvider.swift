// Copyright © 2026 Pharos Solutions. All rights reserved.

import Alamofire
import Foundation
import Moya

final class ApiProvider {
    static let shared = ApiProvider()

    private let provider: MoyaProvider<Endpoint>

    private init(provider: MoyaProvider<Endpoint>? = nil) {
        self.provider = provider ?? MoyaProvider<Endpoint>(
            plugins: [
                AuthPlugin(),
                LanguagePlugin { Language.currentLanguage },
                NetworkLoggerPlugin(configuration: .init(logOptions: [.formatRequestAscURL, .verbose])),
                UnauthorizedPlugin()
            ]
        )
    }

    // MARK: - Completion-based
    func request<T: Decodable>(
        _ endpoint: Endpoint,
        decodeTo type: T.Type,
        completion: @escaping (Swift.Result<T, Error>) -> Void
    ) {
        provider.request(endpoint) { result in
            switch result {
            case let .success(response):
                do {
                    let result: T = try self.result(response: response, decoder: endpoint.decoder)
                    completion(.success(result))
                } catch {
                    completion(.failure(error))
                }
            case let .failure(error):
                let mappedError = self.mapErrors(error)
                completion(.failure(mappedError))
            }
        }
    }

    func request(
        _ endpoint: Endpoint,
        completion: @escaping (Swift.Result<Response, Error>) -> Void
    ) {
        provider.request(endpoint) { result in
            switch result {
            case let .success(response):
                switch response.statusCode {
                case 200 ..< 300:
                    completion(.success(response))
                case 400 ..< 500:
                    do {
                        let error = try endpoint.decoder.decode(EndpointError.self, from: response.data)
                        if HTTPStatusCode(rawValue: response.statusCode) == .unauthorized {
                            completion(.failure(ApiError.unauthorized(error: error.errors.first ?? "")))
                        } else if HTTPStatusCode(rawValue: response.statusCode) == .conflict {
                            completion(.failure(ApiError.conflictError(error.errors.first ?? "")))
                        } else {
                            completion(.failure(ApiError.clientError(statusCode: response.statusCode, clientError: error)))
                        }
                    } catch {
                        completion(.failure(ApiError.clientError(statusCode: response.statusCode, clientError: EndpointError(errors: []))))
                    }
                case 500 ..< 600:
                    completion(.failure(ApiError.serverError(statusCode: response.statusCode)))
                default:
                    completion(.failure(ApiError.unexpectedStatusCode(statusCode: response.statusCode)))
                }
            case let .failure(error):
                let mappedError = self.mapErrors(error)
                completion(.failure(mappedError))
            }
        }
    }

    // MARK: - Upload with progress

    @discardableResult
    func upload<T: Decodable>(
        _ endpoint: Endpoint,
        decodeTo type: T.Type,
        progress: @escaping (Double) -> Void,
        completion: @escaping (Swift.Result<T, Error>) -> Void
    ) -> Cancellable {
        let cancellable = provider.request(
            endpoint,
            callbackQueue: .global(),
            progress: { progressResponse in
                if let progressObject = progressResponse.progressObject {
                    progress(progressObject.fractionCompleted)
                }
            },
            completion: { result in
                switch result {
                case let .success(response):
                    do {
                        let result: T = try self.result(response: response, decoder: endpoint.decoder)
                        completion(.success(result))
                    } catch {
                        completion(.failure(error))
                    }
                case let .failure(error):
                    let mappedError = self.mapErrors(error)
                    completion(.failure(mappedError))
                }
            }
        )
        return cancellable
    }

    // MARK: - Private

    private func result<T: Decodable>(
        response: Response,
        decoder: JSONDecoder
    ) throws -> T {
        switch response.statusCode {
        case 200 ..< 300:
            do {
                return try response.data.decode(decoder)
            } catch {
                throw ApiError.responseDataConversionFailed(error: error.localizedDescription)
            }

        case 400 ..< 500:
            let error = try decoder.decode(EndpointError.self, from: response.data)
            if HTTPStatusCode(rawValue: response.statusCode) == .unauthorized {
                throw ApiError.unauthorized(error: error.errors.first ?? "")
            } else if HTTPStatusCode(rawValue: response.statusCode) == .notFound {
                throw ApiError.clientError(statusCode: response.statusCode, clientError: error)
            } else if HTTPStatusCode(rawValue: response.statusCode) == .conflict {
                throw ApiError.conflictError(error.errors.first ?? "")
            } else {
                throw error
            }

        case 500 ..< 600:
            throw ApiError.serverError(statusCode: response.statusCode)

        default:
            throw ApiError.unexpectedStatusCode(statusCode: response.statusCode)
        }
    }

    private func mapErrors(_ error: Error) -> ApiError {
        if let error = error as? ApiError {
            return error
        }

        guard let error = error as? MoyaError else {
            return .networkError(error.localizedDescription)
        }

        switch error {
        case let .underlying(afError as AFError, _):
            if let nsError = afError.underlyingError as? URLError {
                switch nsError.code {
                case .notConnectedToInternet:
                    return .networkError(L10n.Global.Alerts.noInternetConnection)
                case .timedOut:
                    return .networkError(L10n.Global.Alerts.somethingWentWrong)
                case .networkConnectionLost:
                    return .networkError(L10n.Global.Alerts.noInternetConnection)
                default:
                    return .networkError(error.localizedDescription)
                }
            }
            return .networkError(error.localizedDescription)
        default:
            return .networkError(error.localizedDescription)
        }
    }
}

private extension Data {
    func decode<T: Decodable>(_ decoder: JSONDecoder) throws -> T {
        try decoder.decode(T.self, from: self)
    }
}
