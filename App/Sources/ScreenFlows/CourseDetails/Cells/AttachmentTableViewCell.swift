// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit

class AttachmentTableViewCell: UITableViewCell {
    // MARK: - IBOutlets

    @IBOutlet private var attachmentImageView: UIImageView!
    @IBOutlet private var optionalTitleLabel: UILabel! {
        didSet {
            optionalTitleLabel.text = ""
        }
    }
    @IBOutlet private var subtitleLabel: UILabel!

    // MARK: - Lifestyle

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        attachmentImageView.image = nil
        subtitleLabel.text = nil
        optionalTitleLabel.text = nil
    }

    // MARK: - Public Functions

    internal func setAttachmentImageView(_ image: UIImage) {
        attachmentImageView.image = image
    }

    internal func setOptionalTitleLabel(_ title: String) {
        optionalTitleLabel.text = title
    }

    internal func setSubtitleLabel(_ subtitle: String) {
        subtitleLabel.text = subtitle
    }
}
