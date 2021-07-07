// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit

protocol LoadAttachmentDelegate: AnyObject {
    func loadAttachment(of url: String)
}

internal enum NotificationType {
    case message
    case file
    case course
}

class NotificationTableViewCell: UITableViewCell {
    // MARK: - IBOutlets

    @IBOutlet private var teacherAvatarImageView: UIImageView!
    @IBOutlet private var teacherNameLabel: UILabel!
    @IBOutlet private var notificationContentLabel: UILabel!
    @IBOutlet private var timestampLabel: UILabel!
    @IBOutlet private var attachmentsStackView: UIStackView! {
        didSet {
            attachmentsStackView.alignment = .fill
            attachmentsStackView.distribution = .fillEqually
            attachmentsStackView.spacing = 8.0
        }
    }
    @IBOutlet private var cellContentView: UIView! {
        didSet {
            cellContentView.layer.cornerRadius = UIConstants.cornerRadius
        }
    }

    // MARK: - Public Properties

    internal var type: NotificationType?
    internal weak var loadAttachmentsDelegate: LoadAttachmentDelegate?

    // MARK: - Private Properties

    private var attachments: [Attachment]?

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        configureCellAccordingToType()
    }

    // MARK: - Public Functions

    internal func configureCellAccordingToType() {
        switch self.type {
        case .message:
            attachmentsStackView.isHidden = true
        default:
            return
        }
    }

    internal func configure(using notification: Notification) {
        let inputFormatter = DateFormatter()
        let date = inputFormatter.date(from: notification.createdAt ?? "") ?? Date()
        attachments = notification.attachments
        configureAttachments()
        teacherNameLabel.text = notification.creator
        notificationContentLabel.text = notification.message
        timestampLabel.text = date.formattedDateString
        teacherAvatarImageView.image = Images.person.image
    }

    // MARK: - Private Functions

    private func configureAttachments() {
        guard let attachments = attachments else { return }
        for attachment in attachments {
            let button = UIButton()
            button.tag = attachment.id ?? 0
            button.addTarget(self, action: #selector(loadAttachment(button:)), for: .touchUpInside)
            button.contentHorizontalAlignment = Language.currentLanguage == .english ? .left : .right
            button.setAttributedTitle(getButtonTitle(for: attachment), for: .normal)
            button.titleLabel?.font = UIFont(name: "Inter", size: 14.0)
            button.setTitleColor(Colors.darkGreyColor.color, for: .normal)
            button.translatesAutoresizingMaskIntoConstraints = false
            attachmentsStackView.addArrangedSubview(button)
        }
    }

    private func getButtonTitle(for attachment: Attachment) -> NSMutableAttributedString {
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = getCorrespondingImage(for: attachment)
        imageAttachment.bounds = CGRect(x: 0, y: -5, width: 20, height: 20)
        let attachmentString = NSAttributedString(attachment: imageAttachment)
        let completeText = NSMutableAttributedString(string: "")
        completeText.append(attachmentString)
        let textAfterIcon = NSAttributedString(string: "  \(attachment.filename ?? "attachment")")
        completeText.append(textAfterIcon)
        return completeText
    }

    @objc
    private func loadAttachment(button: UIButton) {
        let attachment = attachments?.first { $0.id == button.tag }
        let documentURL = Environment.baseURL.appendingPathComponent(attachment?.fileUrl ?? "")
        loadAttachmentsDelegate?.loadAttachment(of: "\(documentURL)")
    }

    private func getCorrespondingImage(for attachment: Attachment?) -> UIImage {
        switch attachment?.contentType {
        case "application/pdf":
            return Images.pdfExtension.image
        case "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet":
            return Images.excelExtension.image
        case "application/vnd.openxmlformats-officedocument.wordprocessingml.document":
            return Images.wordExtension.image
        default:
            return Images.unknownExtension.image
        }
    }
}
