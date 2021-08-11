// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit

class AvatarCollectionViewCell: UICollectionViewCell {
    @IBOutlet private var avatarImageView: UIImageView!

    func configure(image: UIImage) {
        avatarImageView.image = image
    }
}
