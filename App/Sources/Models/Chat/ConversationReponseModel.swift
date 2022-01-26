// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

struct ConversationObjectModel: Codable {
    var id: Int
    var adminId: Int
    var studentId: Int
    var closed: Bool
}

struct AttachmentObjectModel: Codable {
    var id: Int?
    var filename: String?
    var fileUrl: String?
    var contentType: String?
}

struct RecivableObjectModel: Codable {
    var name: String
}

struct MessageObjectModel: Codable {
    var id: Int?
    var content: String?
    var createdAt: String
    var sendableId: Int?
    var sendableType: String?
    var receivable: RecivableObjectModel?
    var attachments: [AttachmentObjectModel]?
}

struct WebSocketResponseModel: Codable {
    var identifier: String
    var message: WebSocketMessageModel
}

struct WebSocketMessageModel: Codable {
    var messageApi: MessageObjectModel
}

struct ConversationReponseModel: Codable {
    var conversation: ConversationObjectModel?
    var messages: [MessageObjectModel]?
}
