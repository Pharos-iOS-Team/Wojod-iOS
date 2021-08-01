// Copyright © 2021 Pharos Solutions. All rights reserved.

import AVFoundation
import MessageKit
import UIKit

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
            return .audio(self)
        } else {
            return .custom("")
        }
    }
}

extension MessageObjectModel: AudioItem {
    var url: URL {
        guard let attachmentPath = attachments?.first?.fileUrl,
              let audioURL = URL(string: Environment.baseURLString + attachmentPath) else {
            fatalError("MessagesDisplayDelegate has not been set.")
        }
        return audioURL
    }

    var duration: Float {
        guard let attachmentPath = attachments?.first?.fileUrl else { return 0.0 }
        let asset = AVURLAsset(url: URL(fileURLWithPath: Environment.baseURLString + attachmentPath), options: nil)
        let audioDuration = asset.duration
        let audioDurationSeconds = CMTimeGetSeconds(audioDuration)
        return Float(audioDurationSeconds)
    }

    var size: CGSize {
        return CGSize(width: 180, height: 40)
    }
}
