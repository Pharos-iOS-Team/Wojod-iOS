// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit

internal enum NotificationType {
    case message
    case file
    case course
}

class NotificationTableViewCell: UITableViewCell {
    // MARK: - IBOutlets

    @IBOutlet private var teacherAvatarImageView: UIImageView!
    @IBOutlet private var attachedFileTypeIconImageView: UIImageView!
    @IBOutlet private var teacherNameLabel: UILabel!
    @IBOutlet private var notificationContentLabel: UILabel!
    @IBOutlet private var attachedFileNameLabel: UILabel! {
        didSet {
            attachedFileNameLabel.text = ""
        }
    }
    @IBOutlet private var timestampLabel: UILabel!
    @IBOutlet private var cellContentView: UIView! {
        didSet {
            cellContentView.layer.cornerRadius = UIConstants.cornerRadius
        }
    }

    // MARK: - Public Properties

    internal var type: NotificationType?

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        configureCellAccordingToType()
    }

    // MARK: - Public Functions

    internal func configureCellAccordingToType() {
        switch self.type {
        case .message:
            attachedFileNameLabel.isHidden = true
            attachedFileTypeIconImageView.isHidden = true
        default:
            return
        }
    }

    internal func setTeacherAvatar(_ avatar: UIImage) {
        teacherAvatarImageView.image = avatar
    }

    internal func setTeacherName(_ name: String) {
        teacherNameLabel.text = name
    }

    internal func setNotificationContent(_ content: String) {
        notificationContentLabel.text = content
    }

    internal func setAttachedFileName(_ fileName: String) {
        attachedFileNameLabel.text = fileName
    }

    internal func setTimeStamp(_ timeStampString: String) {
        timestampLabel.text = timeStampString
    }
}
