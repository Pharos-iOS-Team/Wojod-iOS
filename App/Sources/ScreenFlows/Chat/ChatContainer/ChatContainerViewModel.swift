// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

class ChatContainerViewModel {
    var handleEndingChat: (() -> Void)?

    private var model = ChatModel()
    var conversationID: Int?

    func endChat() {
        guard let conversationID = conversationID else { return }
        model.endChat(id: conversationID) { [self] _ in
            handleEndingChat?()
        }
    }
}
