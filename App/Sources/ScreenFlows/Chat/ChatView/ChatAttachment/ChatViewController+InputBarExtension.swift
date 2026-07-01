// Copyright © 2021 Pharos Solutions. All rights reserved.

import AVFoundation
import InputBarAccessoryView
import SwiftEntryKit
import UIKit

extension ChatViewController: InputBarAccessoryViewDelegate {
    func setAttachmentTypeActionSheet() {
        let accessPermissionHandler = AccessPermissionHandler(presentingViewCtrl: self)
        attachmentTypesActionSheet.fileTypeSelectionHandler = { [weak self] in
            self?.pickFile()
        }
        attachmentTypesActionSheet.photoTypeSelectionHandler = { [weak self] in
            accessPermissionHandler.checkPhotoLibraryAuthoriztion {
                self?.pickImage(pickImageFrom: .photoLibrary)
            }
        }
        attachmentTypesActionSheet.cameraTypeSelectionHandler = { [weak self] in
            accessPermissionHandler.checkCameraAuthoriztion {
                self?.pickImage(pickImageFrom: .camera)
            }
        }
    }

    func removeSelectedAttachmentManager() {
        if !attachmentManager.attachments.isEmpty {
            attachmentManager.removeAttachment(at: 0)
        }
    }

    func configureMessageInputBar() {
        messageInputBar.delegate = self
        messageInputBar.sendButton.setTitle("", for: .normal)
        messageInputBar.sendButton.setImage(Asset.Images.sendArrow)
        messageInputBar.shouldAnimateTextDidChangeLayout = true
        messageInputBar.inputPlugins = [attachmentManager]
        messageInputBar.inputTextView.tintColor = ChatConstants.sendButtonColor
        messageInputBar.sendButton.setTitleColor(ChatConstants.sendButtonColor, for: .highlighted)
        setInputBarButtons(isAnyAttachmentSelected: false)
    }

    func setInputBarButtons(isAnyAttachmentSelected: Bool) {
        let addAttachemtnButton = setAddAttachmentButton(isHidden: isAnyAttachmentSelected)
        let startRecordButton = setStartRecordButton(isHidden: isAnyAttachmentSelected)
        let leftStackViewWidth = ChatConstants.inputBarItemWidth * ChatConstants.numberOfLeftInputBarItems
        messageInputBar.setLeftStackViewWidthConstant(to: leftStackViewWidth, animated: true)
        messageInputBar.setStackViewItems([addAttachemtnButton, startRecordButton], forStack: .left, animated: false)
    }

    private func setAddAttachmentButton(isHidden: Bool) -> InputBarButtonItem {
        let button = InputBarButtonItem()
        button.setSize(CGSize(width: ChatConstants.inputBarItemWidth, height: ChatConstants.inputBarItemWidth), animated: false)
        button.setImage(Asset.Images.plusIcn.image, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(addAttachment), for: .touchUpInside)
        button.isHidden = isHidden
        return button
    }

    private func setStartRecordButton(isHidden: Bool) -> InputBarButtonItem {
        let button = InputBarButtonItem()
        button.setSize(CGSize(width: ChatConstants.inputBarItemWidth, height: ChatConstants.inputBarItemWidth), animated: false)
        button.setImage(Asset.Images.audio.image, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(goToRecordView), for: .touchUpInside)
        button.isHidden = isHidden
        return button
    }

    @objc
    private func goToRecordView() {
        let accessPermissionHandler = AccessPermissionHandler(presentingViewCtrl: self)
        accessPermissionHandler.showMissingAudioAutorization {
            DispatchQueue.main.async {
                guard AVAudioSession.sharedInstance().recordPermission == AVAudioSession.RecordPermission.granted else { return }
                let viewCtrl = StoryboardScene.Chat.audioRecordingViewController.instantiate()
                viewCtrl.modalPresentationStyle = .overCurrentContext
                viewCtrl.modalTransitionStyle = .crossDissolve
                viewCtrl.viewModel = self.viewModel
                viewCtrl.handleSendingMessageSuccessfully = {
                    self.messageSentSuccessfully()
                }
                self.present(viewCtrl, animated: true, completion: nil)
            }
        }
    }

    @objc
    private func addAttachment() {
        UIView.animate(
            withDuration: 0.25,
            animations: {
                self.messageInputBar.inputTextView.resignFirstResponder()
                self.messagesCollectionView.scrollToLastItem()
            },
            completion: { _ in
                let attributes = self.attachmentTypesActionSheet.actionSheetAttributes()
                SwiftEntryKit.display(entry: self.attachmentTypesActionSheet, using: attributes)
                self.messagesCollectionView.scrollToLastItem()
            }
        )
    }

    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
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
        setInputBarButtons(isAnyAttachmentSelected: !manager.attachments.isEmpty)
        messageInputBar.sendButton.isEnabled = !manager.attachments.isEmpty
    }

    func attachmentManager(_ manager: AttachmentManager, didInsert attachment: AttachmentManager.Attachment, at index: Int) {
        setInputBarButtons(isAnyAttachmentSelected: !manager.attachments.isEmpty)
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
                cell.imageView.image = Asset.Images.pdfExtension.image
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
            setInputBarButtons(isAnyAttachmentSelected: false)
            viewModel.selectedImage = nil
            viewModel.selectedFile = nil
        }
        topStackView.layoutIfNeeded()
        messagesCollectionView.layoutSubviews()
        messagesCollectionView.scrollToLastItem()
    }
}
