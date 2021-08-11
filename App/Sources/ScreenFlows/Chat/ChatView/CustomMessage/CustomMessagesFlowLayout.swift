// Copyright © 2020 Pharos Solutions. All rights reserved.

import MessageKit
import UIKit

open class CustomMessageSizeCalculator: MessageSizeCalculator {
    let customMessageCell = CustomMessageCell()
    var viewModel: ChatViewModel?

    override init(layout: MessagesCollectionViewFlowLayout? = nil) {
        super.init()
        self.layout = layout
    }

    override open func sizeForItem(at indexPath: IndexPath) -> CGSize {
        let cellWidth: CGFloat = CustomMessageCellConstants.cellwidth
        let messageText = viewModel?.messages[indexPath.section].content ?? ""
        let messageTextHeight = heightForView(text: messageText, width: cellWidth - CustomMessageCellConstants.horizontalPadding)
        let attachmentHeight: CGFloat = CustomMessageCellConstants.attachmentViewHeight
        let verticalPadding: CGFloat = CustomMessageCellConstants.verticalPadding
        let cellHeight = messageTextHeight + attachmentHeight + verticalPadding
        return CGSize(width: cellWidth, height: cellHeight)
    }

    private func heightForView(text: String, width: CGFloat) -> CGFloat {
        let padding: CGFloat = 20
        let actualWidth = width + padding
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: actualWidth, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.text = text
        label.sizeToFit()
        return label.frame.height + 4
    }
}

open class CustomMessagesFlowLayout: MessagesCollectionViewFlowLayout {
    lazy var customMessageSizeCalculator = CustomMessageSizeCalculator(layout: self)

    override open func cellSizeCalculatorForItem(at indexPath: IndexPath) -> CellSizeCalculator {
        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
        if case .custom = message.kind {
            return customMessageSizeCalculator
        }
        return super.cellSizeCalculatorForItem(at: indexPath)
    }

    override open func messageSizeCalculators() -> [MessageSizeCalculator] {
        var superCalculators = super.messageSizeCalculators()
        superCalculators.append(customMessageSizeCalculator)
        return superCalculators
    }
}
