// Copyright © 2021 Pharos Solutions. All rights reserved.

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
    @IBOutlet private var firstStarImageView: UIImageView!
    @IBOutlet private var secondStarImageView: UIImageView!
    @IBOutlet private var thirdStarImageView: UIImageView!
    @IBOutlet private var fourthStarImageView: UIImageView!
    @IBOutlet private var fifthStarImageView: UIImageView!

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
    internal func setRating(_ rating: Int) {
        switch rating {
        case 1:
            firstStarImageView.image = Images.filledStar.image
        case 2:
            firstStarImageView.image = Images.filledStar.image
            secondStarImageView.image = Images.filledStar.image
        case 3:
            firstStarImageView.image = Images.filledStar.image
            secondStarImageView.image = Images.filledStar.image
            thirdStarImageView.image = Images.filledStar.image
        case 4:
            firstStarImageView.image = Images.filledStar.image
            secondStarImageView.image = Images.filledStar.image
            thirdStarImageView.image = Images.filledStar.image
            fourthStarImageView.image = Images.filledStar.image
        case 5:
            firstStarImageView.image = Images.filledStar.image
            secondStarImageView.image = Images.filledStar.image
            thirdStarImageView.image = Images.filledStar.image
            fourthStarImageView.image = Images.filledStar.image
            fifthStarImageView.image = Images.filledStar.image
        default:
            return
        }
    }
}
