// Copyright © 2021 Pharos Solutions. All rights reserved.

import MessageKit
import UIKit

// MARK: - Custom cell Configuration
extension ChatViewController {
    func configureCustomCell() {
        let customMessagesFlowLayout = CustomMessagesFlowLayout()
        customMessagesFlowLayout.customMessageSizeCalculator.viewModel = viewModel
        messagesCollectionView = MessagesCollectionView(frame: .zero, collectionViewLayout: customMessagesFlowLayout)
        messagesCollectionView.registerCell(ofType: CustomMessageCell.self)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        guard let messagesDataSource = messagesCollectionView.messagesDataSource else {
            fatalError("Ouch. nil data source for messages")
        }
        let indexPath = IndexPath(row: 0, section: section)
        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
        let horizontalPadding: CGFloat = ChatConstants.messageHorizontalPadding
        let verticalPadding: CGFloat = ChatConstants.messageVerticalPadding
        if case .custom = message.kind {
            let customCellWidth: CGFloat = CustomMessageCellConstants.cellwidth
            let endPadding = messagesCollectionView.bounds.width - customCellWidth - horizontalPadding
            if isFromCurrentSender(message: message), Language.currentLanguage == .english {
                return UIEdgeInsets(top: verticalPadding, left: endPadding, bottom: verticalPadding, right: horizontalPadding)
            } else if !isFromCurrentSender(message: message), Language.currentLanguage == .arabic {
                return UIEdgeInsets(top: verticalPadding, left: endPadding, bottom: verticalPadding, right: horizontalPadding)
            } else {
                return UIEdgeInsets(top: verticalPadding, left: horizontalPadding, bottom: verticalPadding, right: endPadding)
            }
        }
        return UIEdgeInsets(top: .zero, left: horizontalPadding, bottom: .zero, right: horizontalPadding)
    }
}
