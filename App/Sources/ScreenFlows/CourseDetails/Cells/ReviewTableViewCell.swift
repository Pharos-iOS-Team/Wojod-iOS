// Copyright © 2021 Pharos Solutions. All rights reserved.

import Cosmos
import UIKit

class ReviewTableViewCell: UITableViewCell {
    // MARK: - IBOutlets

    @IBOutlet private var avatarImageView: UIImageView! {
        didSet {
            avatarImageView.layer.cornerRadius = avatarImageView.frame.size.width / 2
        }
    }
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var subtitleLabel: UILabel!
    @IBOutlet private var commentLabel: UILabel!
    @IBOutlet private var ratingView: CosmosView! {
        didSet {
            ratingView.settings.fillMode = .precise
            ratingView.settings.starMargin = 2
            ratingView.isUserInteractionEnabled = false
        }
    }
    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    internal func setAvatarImage(_ image: UIImage?) {
        DispatchQueue.main.async {
            guard let image = image else {
                self.avatarImageView.image = Images.person.image
                return
            }
            self.avatarImageView.image = image
        }
    }

    internal func setTitle(_ title: String) {
        titleLabel.text = title
    }

    internal func setSubtitle(_ subtitle: String) {
        subtitleLabel.text = subtitle
    }

    internal func setComment(_ comment: String) {
        commentLabel.text = comment
    }

    // swiftlint:disable function_body_length
    internal func setRating(_ rating: Double) {
        ratingView.rating = rating
    }
}
