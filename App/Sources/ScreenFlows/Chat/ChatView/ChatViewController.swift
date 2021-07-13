// Copyright © 2021 Pharos Solutions. All rights reserved.

import InputBarAccessoryView
import MessageKit
import UIKit

class ChatViewController: MessagesViewController {
    var setHeaderHandler: ((_: String?, _: Int?) -> Void)?
    let viewModel = ChatViewModel()
    let activityIndicator = ActivityIndicator()
    let attachmentTypesActionSheet = AttachmentTypeActionSheet()
    var socketManager: SocketManager?
    var messagesDisplayHandler: MessagesDisplayHandler?
    var documentPicker: UIDocumentPickerViewController?
    lazy var attachmentManager: AttachmentManager = { [unowned self] in
        let manager = AttachmentManager()
        manager.showAddAttachmentCell = false
        manager.delegate = self
        manager.dataSource = self
        return manager
    }()

    // MARK: - Life cycle
    override func viewDidLoad() {
        configureCustomCell()
        super.viewDidLoad()
        bindViewModel()
        loadConversation()
        configureSocketManager()
        connectToSocket()
        configureMessageCollectionView()
        configureMessageInputBar()
        setAttachmentTypeActionSheet()
        setDocumentPicker()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        becomeFirstResponder()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        disconnectSocket()
        resignFirstResponder()
    }

    // MARK: - Helper Methods

    private func loadConversation() {
        activityIndicator.displayForLoading(in: view)
        viewModel.fetchConversation()
    }

    private func bindViewModel() {
        viewModel.handleSuccessResponse = { [weak self] in
            guard let self = self else { return }
            self.activityIndicator.dismiss()
            self.setHeaderHandler?(self.viewModel.reciverName, self.viewModel.conversationID)
            self.messagesCollectionView.reloadData()
            self.messagesCollectionView.scrollToLastItem()
        }
        viewModel.handleErrorResponse = { error in
            self.activityIndicator.dismiss()
        }
        viewModel.handleSendingMessageSuccess = {
            self.setHeaderHandler?(self.viewModel.reciverName, self.viewModel.conversationID)
            self.messagesCollectionView.reloadData()
            self.messageSentSuccessfully()
        }
    }

    private func messageSentSuccessfully() {
        messageInputBar.sendButton.stopAnimating()
        messageInputBar.inputTextView.placeholder = "Aa"
        configureMessageInputBar()
        setAttachmentManager(active: false)
        removeSelectedAttachmentManager()
        messagesCollectionView.scrollToLastItem()
    }

    // MARK: - handling custom messages
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let messagesDataSource = messagesCollectionView.messagesDataSource else {
            fatalError("Ouch. nil data source for messages")
        }
        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
        if case .custom = message.kind {
            let cell = messagesCollectionView.dequeueReusableCell(CustomMessageCell.self, for: indexPath)
            cell.message = viewModel.messages[indexPath.section]
            cell.isSameSender = isFromCurrentSender(message: message)
            cell.configure(with: message, and: messagesCollectionView)
            cell.openAttachmentHandler = { [weak self] url in
                let documentContainerViewCtrl = StoryboardScene.Chat.documentContainerViewController.instantiate()
                documentContainerViewCtrl.modalPresentationStyle = .overFullScreen
                documentContainerViewCtrl.url = url
                self?.present(documentContainerViewCtrl, animated: true)
            }
            return cell
        }
        return super.collectionView(collectionView, cellForItemAt: indexPath)
    }
}
