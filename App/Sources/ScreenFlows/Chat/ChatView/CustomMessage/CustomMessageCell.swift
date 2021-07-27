// Copyright © 2020 Pharos Solutions. All rights reserved.

import HandyUIKit
import MessageKit
import UIKit

enum CustomMessageCellConstants {
    static let cellwidth: CGFloat = 250
    static let attachmentViewHeight: CGFloat = 60
    static let dateLblHeight: CGFloat = 15
    static let verticalPadding: CGFloat = 30
    static let horizontalPadding: CGFloat = 40
}

class CustomMessageCell: UICollectionViewCell {
    @IBOutlet private var messageContentView: UIView!
    @IBOutlet private var containerStackView: UIStackView!
    @IBOutlet private var contentMessageLbl: UILabel!
    @IBOutlet private var attachmentNameLbl: UILabel!
    @IBOutlet private var attachmentImageView: UIImageView!
    @IBOutlet private var attachmentExtensionLbl: UILabel!
    @IBOutlet private var messageDateLabel: UILabel!
    @IBOutlet private var downloadAttachmentBtn: LoadingButton!

    var message: MessageObjectModel?
    var senderName: String = ""
    var openAttachmentHandler: ((_: URL) -> Void)?
    var isSameSender = Bool()

    // MARK: - SELECTORS AND ACTIONS
    @IBAction private func downloadAttachment() {
        guard let attachment = message?.attachments?.first else { return }
        downloadFile(attachment: attachment)
    }

    @objc
    func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        if let attachment = message?.attachments?.first,
            let filePath = getExistFilePath(attachmentFilePath: attachment.fileUrl ?? "") {
            openAttachmentHandler?(filePath)
        }
    }

    // MARK: - HANDLING DESIGN METHODS

    private func configureCellDesign() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        containerStackView.addGestureRecognizer(tap)
        handleColorsWith(sender: isSameSender)
        messageStyle(sender: isSameSender)
        attachmentImageView.layer.cornerRadius = 4
    }

    private func configureDownloadButton() {
        downloadAttachmentBtn.tintColor = .blue
    }

    private func handleColorsWith(sender: Bool) {
        if sender {
            messageContentView.backgroundColor = ChatConstants.senderBackgroundColor
            contentMessageLbl.textColor = ChatConstants.senderTextColor
            attachmentNameLbl.textColor = ChatConstants.senderTextColor
            attachmentExtensionLbl.textColor = ChatConstants.senderTextColor
        } else {
            messageContentView.backgroundColor = ChatConstants.reciverBackgroundColor
            contentMessageLbl.textColor = ChatConstants.reciverTextColor
            attachmentNameLbl.textColor = ChatConstants.reciverTextColor
            attachmentExtensionLbl.textColor = ChatConstants.reciverTextColor
        }
    }

    private func messageStyle(sender: Bool) {
        if sender {
            messageContentView.setSenderMessageCornerRadius(radius: 15)
            messageDateLabel.textAlignment = .right
        } else {
            messageContentView.setReciverMessageCornerRadius(radius: 15)
            messageDateLabel.textAlignment = .left
        }
    }

    func configure(with message: MessageType, and messagesCollectionView: MessagesCollectionView) {
        fillCellData()
        configureCellDesign()
        downloadAttachmentBtn.isHidden = handleDownloadAttachmentApperance()
    }

    private func fillCellData() {
        contentMessageLbl.text = message?.content
        messageDateLabel.text = DateFormatterHandler.shared.formatStringDateToDateTimeForChat(message?.createdAt ?? "")
        let currentAttachment = message?.attachments?.first
        attachmentNameLbl.text = currentAttachment?.filename ?? "-"
        attachmentExtensionLbl.text = currentAttachment?.contentType ?? ""
        if (currentAttachment?.contentType ?? "").contains("image") {
            attachmentImageView.kf.indicatorType = .activity
            attachmentImageView.kf.setImage(with: URL(string: Environment.baseURLString + (currentAttachment?.fileUrl ?? "")))
        } else if (currentAttachment?.contentType ?? "").contains("pdf") {
            attachmentImageView.image = Asset.Images.pdfIcon.image
        } else {
            attachmentImageView.image = Asset.Images.newGenericExt.image
        }
    }

    // MARK: - HANDLING DOWNLOADING ATTACHMENTS
    private func handleDownloadAttachmentApperance() -> Bool {
        let attachmentPath = message?.attachments?.first?.fileUrl ?? ""
        return (getExistFilePath(attachmentFilePath: attachmentPath) != nil)
    }

    private func getExistFilePath(attachmentFilePath: String) -> URL? {
        guard let attachmentFileURL = URL(string: Environment.baseURLString + attachmentFilePath) else { return nil }
        return FileManager.default.localUrl(ofFileName: attachmentFileURL.lastPathComponent)
    }

    private func downloadFile(attachment: AttachmentObjectModel) {
        downloadAttachmentBtn.startLoading()
        downloadAttachmentBtn.setImage(UIImage())
        let filePath = attachment.fileUrl ?? ""
        guard let url = URL(string: Environment.baseURLString + filePath) else { return }
        let urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        let downloadTask = urlSession.downloadTask(with: url)
        downloadTask.resume()
    }
}

extension CustomMessageCell: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let url = downloadTask.originalRequest?.url else { return }
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let destinationURL = documentsPath.appendingPathComponent(url.lastPathComponent)
        try? FileManager.default.removeItem(at: destinationURL)
        try? FileManager.default.copyItem(at: location, to: destinationURL)
        DispatchQueue.main.sync { [weak self] in
            self?.endDownloading(withURL: destinationURL)
        }
    }

    private func endDownloading(withURL: URL) {
        downloadAttachmentBtn.stopLoading()
        downloadAttachmentBtn.isHidden = true
        openAttachmentHandler?(withURL)
    }
}
