// Copyright © 2021 Pharos Solutions. All rights reserved.

// swiftlint:disable all

import UIKit
import AlamofireImage

class CorrectionImageCollectionViewCell: UICollectionViewCell {

    @IBOutlet private(set) weak var imageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.af.cancelImageRequest()
        imageView.image = nil
    }
}
