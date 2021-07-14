// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation
import Moya

enum ChatTarget {
    case getConversationForSupport
    case getConversationForTeacher(courseID: Int)
    case sendMessageForFirstTime(formData: [Moya.MultipartFormData])
    case sendMessageForteacher(formData: [Moya.MultipartFormData])
    case addMessage(id: Int, formData: [Moya.MultipartFormData])
    case endChat(id: Int)
}

extension ChatTarget: TargetType {
    var path: String {
        switch self {
        case .getConversationForSupport, .sendMessageForFirstTime:
            return "/conversations"
        case let .addMessage(id, _):
            return "/conversations/\(id)/add_message_to_conversation"
        case let .endChat(id):
            return "/conversations/\(id)/close_issue"
        case .getConversationForTeacher, .sendMessageForteacher:
            return "/messages"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getConversationForSupport, .getConversationForTeacher:
            return .get
        case .addMessage, .sendMessageForFirstTime, .endChat, .sendMessageForteacher:
            return .post
        }
    }

    var task: Task {
        switch self {
        case let .getConversationForTeacher(courseID):
            return .requestParameters(
                parameters: ["course_id": courseID],
                encoding: URLEncoding.default
            )
        case .getConversationForSupport, .endChat:
            return .requestPlain
        case .sendMessageForFirstTime(let formData), .addMessage(_, let formData), .sendMessageForteacher(let formData):
            return .uploadMultipart(formData)
        }
    }
}
