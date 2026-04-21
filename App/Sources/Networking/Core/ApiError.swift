// Copyright © 2026 Pharos Solutions. All rights reserved.

import Foundation

enum ApiError: LocalizedError, Equatable {
    case noResponseReceived(error: String?)
    case noDataInResponse
    case responseDataConversionFailed(error: String)
    case unauthorized(error: String)
    case clientError(statusCode: Int, clientError: EndpointError)
    case serverError(statusCode: Int)
    case unexpectedStatusCode(statusCode: Int)
    case networkError(String)
    case conflictError(String)

    var errorDescription: String? {
        switch self {
        case let .noResponseReceived(error):
            return error ?? L10n.Global.Alerts.somethingWentWrong
        case .noDataInResponse:
            return L10n.Global.Alerts.dataPreparationError
        case let .responseDataConversionFailed(error):
            return error
        case let .unauthorized(error):
            return error
        case let .clientError(_, error):
            return error.errorDescription
        case .serverError:
            return L10n.Global.Alerts.somethingWentWrong
        case let .unexpectedStatusCode(statusCode):
            return "Unexpected status code: \(statusCode)"
        case let .networkError(error), let .conflictError(error):
            return error
        }
    }
}
