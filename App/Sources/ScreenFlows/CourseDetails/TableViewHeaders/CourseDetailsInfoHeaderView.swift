// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit

protocol CourseDetailsInfoHeaderDelegate: AnyObject {
    func showDetails()
    func showMaterials()
    func showReviews()
    func goToChat()
    func dismissView()
    func giveReview()
}

struct CourseDetailsInfoModel {
    var courseTitle: String
    var teacherName: String
    var image: UIImage?
    var description: String?
    var price: String
    var numberOfReviews: String
    var rating: Int
    var shouldHideMaterials: Bool
    var delegate: CourseDetailsInfoHeaderDelegate
}

class CourseDetailsInfoHeaderView: UITableViewHeaderFooterView {
    @IBOutlet private var detailsButton: UIButton! {
        didSet {
            detailsButton.setTitle(L10n.CourseDetails.Main.details)
            detailsButton.layer.cornerRadius = UIConstants.cornerRadius
        }
    }
    @IBOutlet private var materialsButton: UIButton! {
        didSet {
            materialsButton.setTitle(L10n.CourseDetails.Main.materials)
            materialsButton.layer.cornerRadius = UIConstants.cornerRadius
        }
    }
    @IBOutlet private var reviewsButton: UIButton! {
        didSet {
            reviewsButton.setTitle(L10n.CourseDetails.Main.reviews)
            reviewsButton.layer.cornerRadius = UIConstants.cornerRadius
        }
    }

    @IBOutlet private var backButton: UIButton! {
        didSet {
            backButton.setImage(Images.localizedWhiteBackButton)
        }
    }
    @IBOutlet private var emptyStateMessageLabel: UILabel! {
        didSet {
            emptyStateMessageLabel.isHidden = true
        }
    }
    @IBOutlet private var playButton: UIButton! {
        didSet {
            playButton.isHidden = true
        }
    }
    @IBOutlet private var mediaContainerView: UIView!
    @IBOutlet private var courseTitle: UILabel!
    @IBOutlet private var teacherNameLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var numberOfReviewsLabel: UILabel!
    @IBOutlet private var priceLabel: UILabel!
    @IBOutlet private var courseImageView: UIImageView!
    @IBOutlet private var firstReviewStar: UIImageView!
    @IBOutlet private var secondReviewStar: UIImageView!
    @IBOutlet private var thirdReviewStar: UIImageView!
    @IBOutlet private var fourthReviewStar: UIImageView!
    @IBOutlet private var fifthReviewStar: UIImageView!
    @IBOutlet private var chatButton: UIButton!

    var delegate: CourseDetailsInfoHeaderDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    @IBAction private func didTapDetails(_ sender: Any) {
        delegate?.showDetails()
    }
    @IBAction private func didTapMaterials(_ sender: Any) {
        delegate?.showMaterials()
    }
    @IBAction private func didTapReviews(_ sender: Any) {
        delegate?.showReviews()
    }
    @IBAction private func didTapPlay(_ sender: Any) {
    }

    func configure(model: CourseDetailsInfoModel) {
        courseTitle.text = model.courseTitle
        teacherNameLabel.text = model.teacherName
        descriptionLabel.text = model.description
        numberOfReviewsLabel.text = model.numberOfReviews
        courseImageView.image = model.image
        priceLabel.text = model.price
        materialsButton.isHidden = model.shouldHideMaterials
        setRating(model.rating)
        delegate = model.delegate
    }

    private func setRating(_ rating: Int) {
        switch rating {
        case 1:
            firstReviewStar.image = Images.filledStar.image
        case 2:
            firstReviewStar.image = Images.filledStar.image
            secondReviewStar.image = Images.filledStar.image
        case 3:
            firstReviewStar.image = Images.filledStar.image
            secondReviewStar.image = Images.filledStar.image
            thirdReviewStar.image = Images.filledStar.image
        case 4:
            firstReviewStar.image = Images.filledStar.image
            secondReviewStar.image = Images.filledStar.image
            thirdReviewStar.image = Images.filledStar.image
            fourthReviewStar.image = Images.filledStar.image
        case 5:
            firstReviewStar.image = Images.filledStar.image
            secondReviewStar.image = Images.filledStar.image
            thirdReviewStar.image = Images.filledStar.image
            fourthReviewStar.image = Images.filledStar.image
            fifthReviewStar.image = Images.filledStar.image
        default:
            return
        }
    }
}
