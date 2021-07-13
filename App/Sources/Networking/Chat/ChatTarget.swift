// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation
import Moya

enum ChatTarget {
    case getConversation
    case sendMessageForFirstTime(formData: [Moya.MultipartFormData])
    case addMessage(id: Int, formData: [Moya.MultipartFormData])
    case endChat(id: Int)
}

extension ChatTarget: TargetType {
    var path: String {
        switch self {
        case .getConversation, .sendMessageForFirstTime:
            return "/conversations"
        case let .addMessage(id, _):
            return "/conversations/\(id)/add_message_to_conversation"
        case let .endChat(id):
            return "/conversations/\(id)/close_issue"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getConversation:
            return .get
        case .addMessage, .sendMessageForFirstTime, .endChat:
            return .post
        }
    }

    var task: Task {
        switch self {
        case .getConversation, .endChat:
            return .requestPlain
        case .sendMessageForFirstTime(let formData), .addMessage(_, let formData):
            return .uploadMultipart(formData)
        }
    }
}
