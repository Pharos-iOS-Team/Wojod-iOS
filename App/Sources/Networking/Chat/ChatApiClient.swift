// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation
import Moya

class ChatApiClient {
    let chatProvider = MoyaProvider<ChatTarget>()

    func loadConversationForTeacher(courseID: Int, completion: @escaping (Response?, MoyaError?) -> Void) {
        chatProvider.request(.getConversationForTeacher(courseID: courseID)) { result in
            switch result {
            case .success(let response):
                completion(response, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    
    func loadConversationForSupport(completion: @escaping (Response?, MoyaError?) -> Void) {
        chatProvider.request(.getConversationForSupport) { result in
            switch result {
            case .success(let response):
                completion(response, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }

    func endChat(id: Int, completion: @escaping (Response?, MoyaError?) -> Void) {
        chatProvider.request(.endChat(id: id)) { result in
            switch result {
            case .success(let response):
                completion(response, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }

    func sendMessage(
        id: Int,
        isFirstMessageInConversation: Bool,
        messageRequestModel: [Moya.MultipartFormData],
        completionHandler: @escaping (Response?, MoyaError?) -> Void
    ) {
        if isFirstMessageInConversation {
            sendMessageForFirstTime(messageRequestModel: messageRequestModel, completion: completionHandler)
        } else {
            addToConversation(id: id, messageRequestModel: messageRequestModel, completion: completionHandler)
        }
    }

    private func sendMessageForFirstTime(messageRequestModel: [Moya.MultipartFormData], completion: @escaping (Response?, MoyaError?) -> Void) {
        chatProvider.request(.sendMessageForFirstTime(formData: messageRequestModel)) { result in
            switch result {
            case .success(let response):
                completion(response, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }

    private func addToConversation(id: Int, messageRequestModel: [Moya.MultipartFormData], completion: @escaping (Response?, MoyaError?) -> Void) {
        chatProvider.request(.addMessage(id: id, formData: messageRequestModel)) { result in
            switch result {
            case .success(let response):
                completion(response, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
}
