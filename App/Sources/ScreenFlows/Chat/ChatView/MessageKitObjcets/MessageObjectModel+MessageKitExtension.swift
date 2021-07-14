// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation
import MessageKit

// MARK: - SenderType
extension MessageObjectModel: SenderType {
    var senderId: String {
        sendableId?.description ?? ""
    }

    var displayName: String {
        sendableType ?? ""
    }
}

// MARK: - MessageType
extension MessageObjectModel: MessageType {
    var sender: SenderType {
        self
    }

    var messageId: String {
        id?.description ?? ""
    }

    var sentDate: Date {
        Date()
    }

    var kind: MessageKind {
        guard let attachment = attachments?.first, let attachmentType = attachment.contentType else { return .text(content ?? "") }
        if attachmentType.contains("audio") {
            return .custom("")
        } else {
            return .custom("")
        }
    }
}
