// Copyright © 2021 Pharos Solutions. All rights reserved.

import InputBarAccessoryView
import SwiftEntryKit
import UIKit

extension ChatViewController: InputBarAccessoryViewDelegate {
    func setAttachmentTypeActionSheet() {
        attachmentTypesActionSheet.fileTypeSelectionHandler = { [weak self] in
            self?.pickFile()
        }
        attachmentTypesActionSheet.photoTypeSelectionHandler = { [weak self] in
            self?.pickImage(pickImageFrom: .photoLibrary)
        }
        attachmentTypesActionSheet.cameraTypeSelectionHandler = { [weak self] in
            self?.pickImage(pickImageFrom: .camera)
        }
    }

    func removeSelectedAttachmentManager() {
        if !attachmentManager.attachments.isEmpty {
            attachmentManager.removeAttachment(at: 0)
        }
    }

    func configureMessageInputBar() {
        messageInputBar.delegate = self
        messageInputBar.sendButton.setTitle(L10n.Chat.send, for: .normal)
        messageInputBar.shouldAnimateTextDidChangeLayout = true
        messageInputBar.inputPlugins = [attachmentManager]
        messageInputBar.inputTextView.tintColor = ChatConstants.sendButtonColor
        messageInputBar.sendButton.setTitleColor(ChatConstants.sendButtonColor, for: .normal)
        messageInputBar.sendButton.setTitleColor(
            ChatConstants.sendButtonColorDimmed,
            for: .highlighted
        )
        setAddAttachmentBtn(isAnyAttachmentSelected: false)
    }

    func setAddAttachmentBtn(isAnyAttachmentSelected: Bool) {
        let button = InputBarButtonItem()
        button.setSize(CGSize(width: 36, height: 36), animated: false)
        button.setImage(Asset.Images.plusIcn.image, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(addAttachment), for: .touchUpInside)
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.setStackViewItems([button], forStack: .left, animated: false)
        button.isHidden = isAnyAttachmentSelected
    }

    @objc
    private func addAttachment() {
        UIView.animate(
            withDuration: 0.25,
            animations: {
                self.messageInputBar.inputTextView.resignFirstResponder()
            },
            completion: { _ in
                let attributes = self.attachmentTypesActionSheet.actionSheetAttributes()
                SwiftEntryKit.display(entry: self.attachmentTypesActionSheet, using: attributes)
            }
        )
    }

    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard ReachabilityAppDelegate.connectionState == .connected else {
            //ErrorView().displayNoInternentConnection()
            return
        }
        messageInputBar.inputTextView.text = String()
        messageInputBar.sendButton.startAnimating()
        messageInputBar.inputTextView.placeholder = L10n.Chat.sending
        viewModel.sendMessage(text: text)
    }
}

// MARK: - AttachmentManagerDelegate
extension ChatViewController: AttachmentManagerDelegate, AttachmentManagerDataSource {
    func attachmentManager(_ manager: AttachmentManager, shouldBecomeVisible: Bool) {
        setAttachmentManager(active: shouldBecomeVisible)
    }

    func attachmentManager(_ manager: AttachmentManager, didReloadTo attachments: [AttachmentManager.Attachment]) {
        setAddAttachmentBtn(isAnyAttachmentSelected: !manager.attachments.isEmpty)
        messageInputBar.sendButton.isEnabled = !manager.attachments.isEmpty
    }

    func attachmentManager(_ manager: AttachmentManager, didInsert attachment: AttachmentManager.Attachment, at index: Int) {
        setAddAttachmentBtn(isAnyAttachmentSelected: !manager.attachments.isEmpty)
        messageInputBar.sendButton.isEnabled = !manager.attachments.isEmpty
    }

    func attachmentManager(_ manager: AttachmentManager, didRemove attachment: AttachmentManager.Attachment, at index: Int) {
        if viewModel.selectedImage != nil {
            viewModel.selectedImage = nil
        } else if viewModel.selectedFile != nil {
            viewModel.selectedFile = nil
        }
        setAttachmentManager(active: false)
        messageInputBar.sendButton.isEnabled = !manager.attachments.isEmpty
    }

    func attachmentManager(_ manager: AttachmentManager, cellFor attachment: AttachmentManager.Attachment, at index: Int) -> AttachmentCell {
        let indexPath = IndexPath(item: index, section: 0)
        let cell = manager.attachmentView.dequeCell(indexPath: indexPath) as ImageAttachmentCell
        cell.indexPath = indexPath
        cell.manager = manager
        if let selectedImage = viewModel.selectedImage {
            cell.imageView.image = selectedImage.image
        }
        if let selectedFile = viewModel.selectedFile {
            if selectedFile.pathExtension.contains("pdf") {
                cell.imageView.image = Asset.Images.pdfIcon.image
            } else {
                cell.imageView.image = Asset.Images.newGenericExt.image
            }
        }
        return cell
    }

    func setAttachmentManager(active: Bool) {
        let topStackView = messageInputBar.topStackView
        if active && !topStackView.arrangedSubviews.contains(attachmentManager.attachmentView) {
            topStackView.insertArrangedSubview(attachmentManager.attachmentView, at: topStackView.arrangedSubviews.count)
        } else if !active && topStackView.arrangedSubviews.contains(attachmentManager.attachmentView) {
            topStackView.removeArrangedSubview(attachmentManager.attachmentView)
            messagesCollectionView.layoutSubviews()
            setAddAttachmentBtn(isAnyAttachmentSelected: false)
            viewModel.selectedImage = nil
            viewModel.selectedFile = nil
        }
        topStackView.layoutIfNeeded()
        messagesCollectionView.layoutSubviews()
        messagesCollectionView.scrollToLastItem()
    }
}
