// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit

class AttachmentTableViewCell: UITableViewCell {
    @IBOutlet private var attachmentImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    internal func setAttachmentImageView(_ image: UIImage) {
        attachmentImageView.image = image
    }
}
