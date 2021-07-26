// Copyright © 2021 Pharos Solutions. All rights reserved.

import MessageKit
import UIKit

// MARK: - Chat Design handler
extension ChatViewController {
    func configureMessageCollectionView() {
        configureMessageDisplayHandler()
        let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout
        configureAvatarLayout(layout: layout)
        setMessageConstraints(layout: layout)
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = messagesDisplayHandler
        scrollsToLastItemOnKeyboardBeginsEditing = true
        maintainPositionOnKeyboardFrameChanged = true
    }

    private func configureMessageDisplayHandler() {
        messagesDisplayHandler = MessagesDisplayHandler { self.isFromCurrentSender(message: $0) }
    }

    private func configureAvatarLayout(layout: MessagesCollectionViewFlowLayout?) {
        layout?.setMessageOutgoingAvatarSize(.zero)
        layout?.setMessageIncomingAvatarSize(.zero)
        layout?.attributedTextMessageSizeCalculator.outgoingAvatarSize = .zero
        layout?.attributedTextMessageSizeCalculator.incomingAvatarSize = .zero
        layout?.textMessageSizeCalculator.outgoingAvatarSize = .zero
        layout?.textMessageSizeCalculator.incomingAvatarSize = .zero
    }

    private func setMessageConstraints(layout: MessagesCollectionViewFlowLayout?) {
        layout?.setMessageIncomingMessageTopLabelAlignment(
            LabelAlignment(
                textAlignment: .left,
                textInsets: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
            )
        )
        layout?.setMessageOutgoingMessageBottomLabelAlignment(
            LabelAlignment(
                textAlignment: .right,
                textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
            )
        )
        layout?.setMessageIncomingMessageBottomLabelAlignment(
            LabelAlignment(
                textAlignment: .left,
                textInsets: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
            )
        )
        layout?.attributedTextMessageSizeCalculator.incomingMessageLabelInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout?.setMessageIncomingAccessoryViewSize(CGSize(width: 30, height: 30))
        layout?.setMessageIncomingAccessoryViewPadding(HorizontalEdgeInsets(left: 8, right: 0))
        layout?.setMessageIncomingAccessoryViewPosition(.messageBottom)
        layout?.setMessageOutgoingAccessoryViewSize(CGSize(width: 30, height: 30))
        layout?.setMessageOutgoingAccessoryViewPadding(HorizontalEdgeInsets(left: 0, right: 8))
    }
}

extension ChatViewController: MessagesDataSource {
    func currentSender() -> SenderType {
        LoggedUserDetails()
    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return viewModel.messages[indexPath.section]
    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        viewModel.messages.count
    }
}

extension ChatViewController: MessagesLayoutDelegate {
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return ChatConstants.messageVerticalPadding
    }

    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        return nil
    }

    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        ChatConstants.messageDateHeight
    }

    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let createdAt = viewModel.messages[indexPath.section].createdAt
        let attributedString = NSMutableAttributedString(
            string: DateFormatterHandler.shared.formatStringDateToDateTimeForChat(createdAt),
            attributes: [.font: ChatConstants.dateFont]
        )
        return attributedString
    }
}
