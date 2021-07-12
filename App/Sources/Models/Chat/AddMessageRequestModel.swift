// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

struct AddMessageForFirstTimeRequestModel: Encodable {
    enum CodingKeys: String, CodingKey {
        case text = "conversation[messages_attributes][][content]"
    }
    var text: String
}

struct AddMessageRequestModel: Encodable {
    enum CodingKeys: String, CodingKey {
        case text = "message[content]"
    }
    var text: String
}
