// Copyright © 2026 Pharos Solutions. All rights reserved.

import Alamofire
import Foundation
import Moya

final class ApiProvider {
    static let shared: ApiProvider = {
        var plugins: [PluginType] = [
            AuthPlugin(),
            LanguagePlugin { Language.currentLanguage },
            UnauthorizedPlugin()
        ]
        #if DEBUG
        plugins.append(NetworkLoggerPlugin(configuration: .init(logOptions: [.formatRequestAscURL, .verbose])))
        #endif

        return ApiProvider(plugins: plugins)
    }()

    private let provider: MoyaProvider<Endpoint>

    init(plugins: [PluginType] = [], provider: MoyaProvider<Endpoint>? = nil) {
        self.provider = provider ?? MoyaProvider<Endpoint>(plugins: plugins)
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
                completion(Result { try self.result(response: response, decoder: endpoint.decoder) })
            case let .failure(error):
                completion(.failure(self.mapErrors(error)))
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
                do {
                    try self.validateStatusCode(response: response, decoder: endpoint.decoder)
                    completion(.success(response))
                } catch {
                    completion(.failure(error))
                }
            case let .failure(error):
                completion(.failure(self.mapErrors(error)))
            }
        }
    }

    // MARK: - Async/Await

    func request<T: Decodable>(
        _ endpoint: Endpoint,
        decodeTo type: T.Type
    ) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            request(endpoint, decodeTo: type) { result in
                continuation.resume(with: result)
            }
        }
    }

    @discardableResult
    func request(_ endpoint: Endpoint) async throws -> Response {
        try await withCheckedThrowingContinuation { continuation in
            request(endpoint) { result in
                continuation.resume(with: result)
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
            callbackQueue: .main,
            progress: { progressResponse in
                if let progressObject = progressResponse.progressObject {
                    progress(progressObject.fractionCompleted)
                }
            },
            completion: { result in
                switch result {
                case let .success(response):
                    completion(Result { try self.result(response: response, decoder: endpoint.decoder) })
                case let .failure(error):
                    completion(.failure(self.mapErrors(error)))
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
        try validateStatusCode(response: response, decoder: decoder)
        do {
            return try response.data.decode(decoder)
        } catch {
            throw ApiError.responseDataConversionFailed(error: error.localizedDescription)
        }
    }

    private func validateStatusCode(response: Response, decoder: JSONDecoder) throws {
        switch response.statusCode {
        case 200 ..< 300:
            return
        case 400 ..< 500:
            let endpointError = (try? decoder.decode(EndpointError.self, from: response.data)) ?? EndpointError(errors: [])
            let errorMessage = endpointError.errors.first ?? ""
            switch HTTPStatusCode(rawValue: response.statusCode) {
            case .unauthorized:
                throw ApiError.unauthorized(error: errorMessage)
            case .notFound:
                throw ApiError.clientError(statusCode: response.statusCode, clientError: endpointError)
            case .conflict:
                throw ApiError.conflictError(errorMessage)
            default:
                throw ApiError.clientError(statusCode: response.statusCode, clientError: endpointError)
            }
        case 500 ..< 600:
            throw ApiError.serverError(statusCode: response.statusCode)
        default:
            throw ApiError.unexpectedStatusCode(statusCode: response.statusCode)
        }
    }

    private func mapErrors(_ error: Error) -> ApiError {
        if let apiError = error as? ApiError {
            return apiError
        }
        if
            let moyaError = error as? MoyaError,
            case let .underlying(afError as AFError, _) = moyaError,
            let urlError = afError.underlyingError as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost:
                return .networkError(L10n.Global.Alerts.noInternetConnection)
            default:
                return .networkError(L10n.Global.Alerts.somethingWentWrong)
            }
        }
        return .networkError(error.localizedDescription)
    }
}

private extension Data {
    func decode<T: Decodable>(_ decoder: JSONDecoder) throws -> T {
        try decoder.decode(T.self, from: self)
    }
}
