// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

enum ChatType: Equatable {
    case teacher(courseID: Int, teacherID: Int)
    case customerSupport
}

class ChatContainerViewModel {
    var handleEndingChat: (() -> Void)?
    var conversationID: Int?

    private var model = ChatModel()

    func endChat() {
        guard let conversationID = conversationID else { return }
        model.endChat(id: conversationID) { [self] _ in
            handleEndingChat?()
        }
    }
}
