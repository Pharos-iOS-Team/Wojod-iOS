// Copyright © 2021 Pharos Solutions. All rights reserved.

import Cosmos
import Kingfisher
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
            ratingView.semanticContentAttribute = Language.semanticContent
            ratingView.settings.fillMode = .precise
            ratingView.settings.starMargin = 2
            ratingView.isUserInteractionEnabled = false
        }
    }
    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configure(with review: Review) {
        titleLabel.text = review.title ?? ""
        let date = DateFormatter.isoDateFormatter.date(from: review.createdAt ?? "")
        subtitleLabel.text = "\(date?.formatDateToDateTimeString ?? "") \(L10n.CourseDetails.CourseReview.by) \(review.reviewer?.name ?? "")"
        commentLabel.text = review.comment ?? ""
        ratingView.rating = review.rating ?? 0.0

        let avatarURLString = AppEnvironment.baseURLString + (review.reviewer?.avatar?.fileUrl ?? "")
        if let avatarURL = URL(string: avatarURLString) {
            KingfisherManager.shared.retrieveImage(with: avatarURL) { [weak self] result in
                DispatchQueue.main.async {
                    if case .success(let value) = result {
                        self?.avatarImageView.image = value.image
                    } else {
                        self?.avatarImageView.image = Images.person.image
                    }
                }
            }
        } else {
            avatarImageView.image = Images.person.image
        }
    }
}
