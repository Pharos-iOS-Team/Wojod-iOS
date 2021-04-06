// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

enum ErrorType: Equatable {
    case validationError
    case serverSideError(statusCode: Int? = nil)
    case connectivityError
}

struct CustomError: Error {
    var type: ErrorType
    var message: String

    init(type: ErrorType, message: String = "") {
        self.type = type
        self.message = message
    }
}
