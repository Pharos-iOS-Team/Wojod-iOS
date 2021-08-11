// Copyright © 2021 Pharos Solutions. All rights reserved.

import Foundation

extension ChatViewController: SocketManagerDelegate {
    // MARK: - Socket connection

    func configureSocketManager() {
        socketManager = SocketManager(conversationID: viewModel.conversationID ?? 0, chatType: viewModel.chatType)
        socketManager?.delegate = self
    }

    func connectToSocket() {
        socketManager?.connect()
    }

    func disconnectSocket() {
        socketManager?.disconnect()
    }

    func didReceiveMessage(_ message: String) {
        if viewModel.decodeReceivedMessageFromWebSocket(from: message) != nil {
            self.messagesCollectionView.reloadData()
            self.messagesCollectionView.scrollToLastItem()
        }
    }
}
