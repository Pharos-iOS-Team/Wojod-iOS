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
    var chatType: ChatType = .customerSupport

    // MARK: - Init
    init() {
        model = ChatModel()
    }

    // MARK: - public methods
    func fetchConversation() {
        switch chatType {
        case let .teacher(courseID, _):
            fetchConversationForTeacher(id: courseID)
        case .customerSupport:
            fetchConversationForCustomerSupport()
        }
    }

    private func fetchConversationForTeacher(id: Int) {
        model.fetchConversationForTeacher(courseID: id) { [self] result in
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

    private func fetchConversationForCustomerSupport() {
        model.fetchConversationForSupport { [self] result in
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
        messages += conversation.messages?.reversed() ?? []
        isStartingConversation = messages.isEmpty
        conversationID = conversation.conversation?.id
        reciverName = conversation.messages?.last?.receivable?.name ?? ""
    }

    func sendMessage(text: String) {
        let messageRequestBody = createMessageRequestModel(text: text, isFirstMessage: isStartingConversation)
        model.addMessage(
            isSendToTeacher: chatType != .customerSupport,
            isFirstMessage: isStartingConversation,
            id: conversationID ?? 0,
            messageRequestModel: messageRequestBody
        ) { [self] result in
            switch result {
            case .success(let conversation as ConversationReponseModel):
                selectedImage = nil
                selectedFile = nil
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
        var requestModel: Encodable?
        var attachmentKey = ""
        switch chatType {
        case let .teacher(courseID, teacherID):
            requestModel = AddMessageForTeacherRequestModel(text: text, receivableId: "\(teacherID)", courseId: "\(courseID)")
            attachmentKey = AddMessageForTeacherRequestModel.attachmentKey
        case .customerSupport:
            if isFirstMessage {
                requestModel = AddMessageForFirstTimeRequestModel(text: text)
                attachmentKey = AddMessageForFirstTimeRequestModel.attachmentKey
            } else {
                requestModel = AddMessageRequestModel(text: text)
                attachmentKey = AddMessageRequestModel.attachmentKey
            }
        }
        guard let requestDictionary = requestModel?.dictionary else { return [] }
        return getFormData(requestDictionary: requestDictionary, attachmentKey: attachmentKey)
    }

    private func getFormData(requestDictionary: [String: Any], attachmentKey: String) -> [Moya.MultipartFormData] {
        var formDataArr = [Moya.MultipartFormData]()
        formDataArr.append(
            contentsOf: FormDataGenerator.getDictionaryFormData(requestDictionary: requestDictionary)
        )
        if let attachmentImage = selectedImage {
            formDataArr.append(
                contentsOf: FormDataGenerator.getImagesFormData(
                    images: [attachmentImage],
                    key: attachmentKey
                )
            )
        } else if let attachmentFiles = selectedFile {
            formDataArr.append(
                contentsOf: FormDataGenerator.getFilesFormData(
                    files: [attachmentFiles],
                    key: attachmentKey
                )
            )
        }
        return formDataArr
    }

    func decodeReceivedMessageFromWebSocket(from text: String) -> MessageObjectModel? {
        guard let data = text.data(using: .utf8) else { return nil }
        let decodedResponse = CoursesDecoder.decode(modelType: WebSocketResponseModel.self, from: data)
        guard let decodedMessage = decodedResponse.data?.message.messageApi else { return nil }
        messages.append(decodedMessage)
        return decodedMessage
    }
}
