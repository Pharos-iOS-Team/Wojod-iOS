// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation
import Moya

class ChatModel {
    func fetchConversationForTeacher(courseID: Int, completion: @escaping (Swift.Result<ConversationReponseModel, Error>) -> Void) {
        let requestModel = GetConversationForTeacherRequestModel(courseId: courseID)
        ApiProvider.shared.request(.chat(.getConversationForTeacher(requestModel)), decodeTo: ConversationReponseModel.self, completion: completion)
    }

    func fetchConversationForSupport(completion: @escaping (Swift.Result<ConversationReponseModel, Error>) -> Void) {
        ApiProvider.shared.request(.chat(.getConversationForSupport), decodeTo: ConversationReponseModel.self, completion: completion)
    }

    func endChat(id: Int, completion: @escaping (Swift.Result<ConversationReponseModel, Error>) -> Void) {
        ApiProvider.shared.request(.chat(.endChat(id: id)), decodeTo: ConversationReponseModel.self, completion: completion)
    }

    func addMessage(
        isSendToTeacher: Bool,
        isFirstMessage: Bool,
        id: Int,
        messageRequestModel: [Moya.MultipartFormData],
        completion: @escaping (Swift.Result<ConversationReponseModel, Error>) -> Void
    ) {
        let endpoint: Endpoint = {
            if isFirstMessage {
                return .chat(.sendMessageForFirstTime(formData: messageRequestModel))
            } else if isSendToTeacher {
                return .chat(.sendMessageForTeacher(formData: messageRequestModel))
            } else {
                return .chat(.addMessage(id: id, formData: messageRequestModel))
            }
        }()
        ApiProvider.shared.request(endpoint, decodeTo: ConversationReponseModel.self, completion: completion)
    }
}
