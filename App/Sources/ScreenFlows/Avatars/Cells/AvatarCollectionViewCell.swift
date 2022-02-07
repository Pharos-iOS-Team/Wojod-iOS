// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit

class AvatarCollectionViewCell: UICollectionViewCell {
    @IBOutlet private var avatarImageView: UIImageView!

    var isCellSelected: Bool = false

    func configure(image: UIImage, isSelected: Bool) {
        isCellSelected = isSelected
        isCellSelected ? selectImage() : unselectImage()
        avatarImageView.image = image
    }

    internal func selectImage() {
        avatarImageView.alpha = 1.0
    }

    internal func unselectImage() {
        avatarImageView.alpha = 0.5
    }
}
