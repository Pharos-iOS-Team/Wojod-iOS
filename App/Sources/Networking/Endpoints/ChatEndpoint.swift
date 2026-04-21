// Copyright © 2026 Pharos Solutions. All rights reserved.

import Foundation
import Moya

enum ChatEndpoint {
    case getConversationForSupport
    case getConversationForTeacher(GetConversationForTeacherRequestModel)
    case sendMessageForFirstTime(formData: [Moya.MultipartFormData])
    case sendMessageForTeacher(formData: [Moya.MultipartFormData])
    case addMessage(id: Int, formData: [Moya.MultipartFormData])
    case endChat(id: Int)
}

extension ChatEndpoint: TargetType {
    var path: String {
        switch self {
        case .getConversationForSupport, .sendMessageForFirstTime:
            return "/conversations"
        case let .addMessage(id, _):
            return "/conversations/\(id)/add_message_to_conversation"
        case let .endChat(id):
            return "/conversations/\(id)/close_issue"
        case .getConversationForTeacher, .sendMessageForTeacher:
            return "/messages"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getConversationForSupport, .getConversationForTeacher:
            return .get
        case .addMessage, .sendMessageForFirstTime, .endChat, .sendMessageForTeacher:
            return .post
        }
    }

    var task: Task {
        switch self {
        case let .getConversationForTeacher(requestModel):
            return .queryParameters(requestModel)

        case let .sendMessageForFirstTime(formData), let .addMessage(_, formData), let .sendMessageForTeacher(formData):
            return .uploadMultipart(formData)

        default:
            return .requestPlain
        }
    }
}
