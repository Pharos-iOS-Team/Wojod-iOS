// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation
import Moya
import UIKit

class ChatViewModel {
    // clousers
    var handleSuccessResponse: (() -> Void)?
    var handleSendingMessageSuccess: (() -> Void)?
    var handleEndingChat: (() -> Void)?
    var handleErrorResponse: ((_: String?) -> Void)?

    // private vars
    private var model: ChatModel
    private var isStartingConversation = true

    // public vars
    var messages: [MessageObjectModel] = []
    var conversationID: Int?
    var reciverName: String?
    var selectedImage: ImageAttachmentDetails?
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
                handleSuccessRequest(response: conversation)
                handleSuccessResponse?()
            case .failure(let error):
                handleErrorResponse?(error.message)
            default:
                self.handleErrorResponse?(nil)
            }
        }
    }

    private func handleSuccessRequest(response conversation: ConversationReponseModel) {
        messages += conversation.messages ?? []
        isStartingConversation = messages.isEmpty
        conversationID = conversation.conversation?.id
        reciverName = conversation.messages?.last?.receivable?.name ?? ""
    }

    func sendMessage(text: String) {
        let messageRequestBody = createMessageRequestModel(text: text, isFirstMessage: isStartingConversation)
        model.addMessage(
            isFirstMessage: isStartingConversation,
            id: conversationID ?? 0,
            messageRequestModel: messageRequestBody
        ) { [self] result in
            switch result {
            case .success(let conversation as ConversationReponseModel):
                handleSuccessRequest(response: conversation)
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
        formDataArr.append(
            contentsOf: FormDataGenerator.getDictionaryFormData(requestDictionary: requestDictionary)
        )
        if let attachmentImage = selectedImage {
            formDataArr.append(
                contentsOf: FormDataGenerator.getImagesFormData(
                    images: [attachmentImage],
                    key: isStartingConversation ? "conversation[messages_attributes][][attachments][]" : "message[attachments][]"
                )
            )
        } else if let attachmentFiles = selectedFile {
            formDataArr.append(
                contentsOf: FormDataGenerator.getFilesFormData(
                    files: [attachmentFiles],
                    key: isStartingConversation ? "conversation[messages_attributes][][attachments][]" : "message[attachments][]"
                )
            )
        }
        return formDataArr
    }
}
