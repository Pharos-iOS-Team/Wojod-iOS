// Copyright © 2021 Pharos Solutions. All rights reserved.

import AVFoundation
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
    var chatType: ChatType = .customerSupport
    var audioController: BasicAudioController?
    var lastAudioIndexPathClicked: IndexPath?
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
        setViewModel()
        bindViewModel()
        loadConversation()
        connectToSocket()
        configureMessageCollectionView()
        configureMessageInputBar()
        setAttachmentTypeActionSheet()
        setDocumentPicker()
        configureAudioController()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        becomeFirstResponder()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        disconnectSocket()
        audioController?.dinitAudioPlayer()
        audioController = nil
        resignFirstResponder()
    }

    // MARK: - Helper Methods

    private func configureAudioController() {
        audioController = BasicAudioController(messageCollectionView: messagesCollectionView)
    }

    private func setViewModel() {
        viewModel.chatType = chatType
    }

    private func loadConversation() {
        activityIndicator.displayForLoading(in: view)
        viewModel.fetchConversation()
    }

    private func bindViewModel() {
        viewModel.handleSuccessResponse = { [weak self] in
            guard let self = self else { return }
            self.setHeaderHandler?(self.viewModel.reciverName, self.viewModel.conversationID)
            self.messagesCollectionView.reloadData()
            self.messagesCollectionView.scrollToLastItem()
            self.configureSocketManager()
            self.connectToSocket()
            self.activityIndicator.dismiss()
        }
        viewModel.handleErrorResponse = { error in
            self.activityIndicator.dismiss()
            AlertHandler(presentingViewCtrl: self).showConfirmAlert(
                title: L10n.Global.Titles.error,
                message: error ?? ""
            )
        }
        viewModel.handleSendingMessageSuccess = {
            self.setHeaderHandler?(self.viewModel.reciverName, self.viewModel.conversationID)
            self.messageSentSuccessfully()
        }
    }

    func messageSentSuccessfully() {
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToLastItem()
        messageInputBar.sendButton.stopAnimating()
        messageInputBar.inputTextView.placeholder = "Aa"
        configureMessageInputBar()
        setAttachmentManager(active: false)
        removeSelectedAttachmentManager()
        handleWebSocketConfigurationIfneeded()
    }

    private func handleWebSocketConfigurationIfneeded() {
        let isFirstMessage = viewModel.messages.count == 1
        if isFirstMessage {
            self.configureSocketManager()
            self.connectToSocket()
        }
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
