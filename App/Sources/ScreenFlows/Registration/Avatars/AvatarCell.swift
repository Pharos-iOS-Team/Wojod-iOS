// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit

class AvatarCell: UICollectionViewCell {
    // MARK: - IBOutlets

    @IBOutlet private var avatarImageView: UIImageView!

    // MARK: - Public Functions

    internal func setImageView(with avatar: UIImage) {
        avatarImageView.image = avatar
    }

    internal func selectImage() {
        avatarImageView.alpha = 1.0
    }

    internal func unselectImage() {
        avatarImageView.alpha = 0.5
    }
}
