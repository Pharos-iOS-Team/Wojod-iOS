// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

struct AddMessageForFirstTimeRequestModel: Encodable {
    enum CodingKeys: String, CodingKey {
        case text = "conversation[messages_attributes][][content]"
    }

    static var attachmentKey = "conversation[messages_attributes][][attachments][]"
    var text: String
}

struct AddMessageForTeacherRequestModel: Encodable {
    enum CodingKeys: String, CodingKey {
        case text = "message[content]"
        case receivableId = "message[receivable_id]"
        case receivableType = "message[receivable_type]"
        case courseId = "message[course_id]"
    }

    static var attachmentKey = "message[attachments][]"
    var text: String
    var receivableId: String
    var receivableType: String = "Admin"
    var courseId: String
}

struct AddMessageRequestModel: Encodable {
    enum CodingKeys: String, CodingKey {
        case text = "message[content]"
    }

    static var attachmentKey = "message[attachments][]"
    var text: String
}
