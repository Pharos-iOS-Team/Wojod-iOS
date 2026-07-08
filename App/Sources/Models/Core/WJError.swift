// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

struct WJError: Error {
    enum ErrorType: Equatable {
        case validationError
        case serverSideError(statusCode: HTTPStatusCode? = nil)
        case connectivityError
        case parsingError
    }

    var type: ErrorType
    var message: String

    init(type: ErrorType, message: String = "") {
        self.type = type
        self.message = message
    }
}
