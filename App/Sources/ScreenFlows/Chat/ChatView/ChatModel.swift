// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation
import Moya

class ChatModel: ModelDecodable {
    let apiClient = ChatApiClient()

    func fetchConversationForTeacher(courseID: Int, completion: @escaping (Result) -> Void) {
        apiClient.loadConversationForTeacher(courseID: courseID) { response, error in
            if let response = response {
                if response.statusCode < 300 {
                    self.decode(modelType: ConversationReponseModel.self, from: response) { result in
                        completion(result)
                    }
                } else {
                    self.decodeError(response: response, completionHandler: completion)
                }
            } else if let error = error {
                completion(.failure(WJError(type: .parsingError, message: error.localizedDescription)))
            }
        }
    }

    func fetchConversationForSupport(completion: @escaping (Result) -> Void) {
        apiClient.loadConversationForSupport { response, error in
            if let response = response {
                if response.statusCode < 300 {
                    self.decode(modelType: ConversationReponseModel.self, from: response) { result in
                        completion(result)
                    }
                } else {
                    self.decodeError(response: response, completionHandler: completion)
                }
            } else if let error = error {
                completion(.failure(WJError(type: .parsingError, message: error.localizedDescription)))
            }
        }
    }

    func endChat(id: Int, completion: @escaping (Result) -> Void) {
        apiClient.endChat(id: id) { response, error in
            if let response = response {
                if response.statusCode < 300 {
                    self.decode(modelType: ConversationReponseModel.self, from: response) { result in
                        completion(result)
                    }
                } else {
                    self.decodeError(response: response, completionHandler: completion)
                }
            } else if let error = error {
                completion(.failure(WJError(type: .parsingError, message: error.localizedDescription)))
            }
        }
    }

    func addMessage(
        isSendToTeacher: Bool,
        isFirstMessage: Bool,
        id: Int,
        messageRequestModel: [Moya.MultipartFormData],
        completion: @escaping (Result) -> Void
    ) {
        apiClient.sendMessage(
            id: id,
            isSendToTeacher: isSendToTeacher,
            isFirstMessageInConversation: isFirstMessage,
            messageRequestModel: messageRequestModel
        ) { response, error in
            if let response = response {
                if response.statusCode < 300 {
                    self.decode(modelType: ConversationReponseModel.self, from: response) { result in
                        completion(result)
                    }
                } else {
                    self.decodeError(response: response, completionHandler: completion)
                }
            } else if let error = error {
                completion(.failure(WJError(type: .parsingError, message: error.localizedDescription)))
            }
        }
    }
}
