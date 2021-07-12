// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation
import Moya

class ChatModel: ModelDecodable {
    let apiClient = ChatApiClient()

    func fetchConversation(completion: @escaping (Result) -> Void) {
        apiClient.loadConversation { response, error in
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

    func addMessage(isFirstMessage: Bool, id: Int, messageRequestModel: [Moya.MultipartFormData], completion: @escaping (Result) -> Void) {
        apiClient.sendMessage(id: id, isFirstMessageInConversation: isFirstMessage, messageRequestModel: messageRequestModel) { response, error in
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
