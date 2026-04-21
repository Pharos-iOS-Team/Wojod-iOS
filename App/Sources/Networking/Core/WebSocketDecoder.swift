// Copyright © 2026 Pharos Solutions. All rights reserved.

import Foundation

enum WebSocketDecoder {
    static func decodeMessage(from text: String) -> MessageObjectModel? {
        guard
        let data = text.data(using: .utf8),
        let decodedResponse = try? JSONDecoder.default.decode(WebSocketResponseModel.self, from: data)
        else { return nil }
        return decodedResponse.message.messageApi
    }
}
