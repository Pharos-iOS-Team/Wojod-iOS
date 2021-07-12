// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation
import Moya
import UIKit

class ChatViewModel {
    // clousers
    var handleSuccessResponse: (() -> Void)?
    var handleSendingMessageSuccess: (() -> Void)?
    var handleErrorResponse: ((_: String?) -> Void)?

    // private vars
    private var model: ChatModel

    // public vars
    var messages: [MessageObjectModel] = []
    var conversationID: Int?
    var reciverName: String?
    var selectedImage: UIImage?
    var selectedFile: URL?

    // MARK: - Init
    init() {
        model = ChatModel()
    }

    // MARK: - public methods
    func fetchConversation() {
        model.fetchConversation { [self] result in
            switch result {
            case .success(let conversation as ConversationReponseModel):
                messages += conversation.messages ?? []
                conversationID = conversation.conversation?.id
                reciverName = conversation.messages?.last?.receivable?.name ?? ""
                handleSuccessResponse?()
            case .failure(let error):
                handleErrorResponse?(error.message)
            default:
                self.handleErrorResponse?(nil)
            }
        }
    }

    func sendMessage(text: String) {
        let messageRequestBody = createMessageRequestModel(text: text, isFirstMessage: messages.isEmpty)
        model.addMessage(
            isFirstMessage: messages.isEmpty,
            id: conversationID ?? 0,
            messageRequestModel: messageRequestBody
        ) { [self] result in
            switch result {
            case .success(let conversation as ConversationReponseModel):
                messages += conversation.messages ?? []
                reciverName = conversation.messages?.last?.receivable?.name ?? ""
                handleSendingMessageSuccess?()
            case .failure(let error):
                handleErrorResponse?(error.message)
            default:
                self.handleErrorResponse?(nil)
            }
        }
    }

    private func createMessageRequestModel(text: String, isFirstMessage: Bool) -> [Moya.MultipartFormData] {
        if isFirstMessage {
            let requestModel = AddMessageForFirstTimeRequestModel(text: text)
            guard let requestDictionary = requestModel.dictionary else { return [] }
            return getFormData(requestDictionary: requestDictionary)
        } else {
            let requestModel = AddMessageRequestModel(text: text)
            guard let requestDictionary = requestModel.dictionary else { return [] }
            return getFormData(requestDictionary: requestDictionary)
        }
    }

    private func getFormData(requestDictionary: [String: Any]) -> [Moya.MultipartFormData] {
        var formDataArr = [Moya.MultipartFormData]()
        for (key, value) in requestDictionary {
            let dataOfValue = getDataFrom(value)
            let formData = Moya.MultipartFormData(provider: .data(dataOfValue), name: key)
            formDataArr.append(formData)
        }
        return formDataArr
    }

    private func getDataFrom(_ value: Any) -> Data {
        if let value = value as? String {
            return value.data(using: String.Encoding.utf8) ?? Data()
        } else if let value = value as? [String] {
            var valueData = Data()
            for string in value {
                valueData.append(string.data(using: String.Encoding.utf8) ?? Data())
            }
            return valueData
        } else {
            return Data()
        }
    }
}
