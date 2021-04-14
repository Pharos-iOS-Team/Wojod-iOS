// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit

class AvatarCollectionViewCell: UICollectionViewCell {
    // MARK: - IBOutlets

    @IBOutlet private var avatarImageView: UIImageView!

    // MARK: - Public Functions

    internal func setImageView(with avatar: UIImage) {
        avatarImageView.image = avatar
    }

    internal func unselectImage() {
        avatarImageView.layer.borderWidth = 0
    }

    internal func selectImage() {
        avatarImageView.layer.borderWidth = 2.0
        avatarImageView.layer.borderColor = Colors.sendButtonColor.color.cgColor
    }
}
