// Copyright © 2020 Pharos Solutions. All rights reserved.

import MessageKit
import UIKit

class MessagesDisplayHandler: MessagesDisplayDelegate {
    var isMessageFromCurrentSender: (MessageType) -> Bool

    init(isMessageFromCurrentSender: @escaping (MessageType) -> Bool) {
        self.isMessageFromCurrentSender = isMessageFromCurrentSender
    }

    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        isMessageFromCurrentSender(message) ? ChatConstants.senderTextColor : ChatConstants.reciverTextColor
    }

    func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedString.Key: Any] {
        switch detector {
        case .hashtag, .mention:
            return [.foregroundColor: UIColor.blue]
        default:
            return MessageLabel.defaultAttributes
        }
    }

    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        [.url, .address, .phoneNumber, .date, .transitInformation, .mention, .hashtag]
    }

    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        isMessageFromCurrentSender(message) ? ChatConstants.senderBackgroundColor : ChatConstants.reciverBackgroundColor
    }

    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        avatarView.isHidden = true
    }

    @MainActor func configureMediaMessageImageView(
        _ imageView: UIImageView,
        for message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView
    ) {
        let mediaMessage = message as? MessageObjectModel
        let attachmentUrl = mediaMessage?.attachments?.first?.fileUrl
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(with: URL(string: AppEnvironment.baseURLString + (attachmentUrl ?? "")))
    }

    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let roundedCorners: UIRectCorner = [
            isMessageFromCurrentSender(message) ? .topLeft: .topRight,
            .bottomLeft,
            .bottomRight
        ]
        return .custom { $0.roundCorners(roundedCorners, radius: 8) }
    }
}
