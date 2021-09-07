// Copyright © 2021 Pharos Solutions. All rights reserved.

import AVKit
import UIKit

protocol CourseDetailsInfoHeaderDelegate: AnyObject {
    func showDetails()
    func showMaterials()
    func showReviews()
    func goToChat()
    func dismissView()
    func playCourseVideo(playerController: AVPlayerViewController)
}

enum DetailsButtonSelected {
    case details
    case materials
    case reviews
}

struct CourseDetailsInfoModel {
    var courseTitle: String
    var teacherName: String
    var image: UIImage?
    var video: Media?
    var description: String?
    var price: String
    var numberOfReviews: String
    var rating: Int
    var shouldHideMaterials: Bool
    var buttonSelected: DetailsButtonSelected
    var state: CourseState
    weak var delegate: CourseDetailsInfoHeaderDelegate?
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

    weak var delegate: CourseDetailsInfoHeaderDelegate?
    var video: Media?

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
        playButton.isHidden = true
        let courseVideoUrl = video?.fileUrl ?? ""
        guard let videoURL = URL(string: "\(Environment.baseURL)" + courseVideoUrl) else { return }
        let player = AVPlayer(url: videoURL)
        let playerController = AVPlayerViewController()
        playerController.player = player
        delegate?.playCourseVideo(playerController: playerController)
        playerController.view.frame = self.courseImageView.frame
        self.mediaContainerView.insertSubview(playerController.view, at: (self.mediaContainerView.subviews.firstIndex(of: courseImageView) ?? 0) + 1)
        player.play()
    }
    @IBAction private func didTapChatButton(_ sender: Any) {
        delegate?.goToChat()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configure(model: CourseDetailsInfoModel) {
        courseTitle.text = model.courseTitle
        teacherNameLabel.text = model.teacherName
        descriptionLabel.text = model.description
        numberOfReviewsLabel.text = model.numberOfReviews
        courseImageView.image = model.image
        priceLabel.text = model.price
        materialsButton.isHidden = model.shouldHideMaterials
        configureChatButtonAccordingToState(state: model.state)
        video = model.video
        playButton.isHidden = video?.fileUrl == nil || video?.fileUrl?.isEmpty ?? true
        setRating(model.rating)
        configureButtonSelected(buttonSelected: model.buttonSelected)
        delegate = model.delegate
    }

    // swiftlint:disable function_body_length
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

    private func configureButtonSelected(buttonSelected: DetailsButtonSelected) {
        switch buttonSelected {
        case .details:
            selectButton(button: detailsButton)
            unselectButton(button: materialsButton)
            unselectButton(button: reviewsButton)
        case .materials:
            selectButton(button: materialsButton)
            unselectButton(button: detailsButton)
            unselectButton(button: reviewsButton)
        case .reviews:
            selectButton(button: reviewsButton)
            unselectButton(button: materialsButton)
            unselectButton(button: detailsButton)
        }
    }

    private func selectButton(button: UIButton) {
        button.layer.backgroundColor = Colors.lightAccentColor.color.cgColor
        button.setTitleColor(Colors.sendButtonColor.color, for: .normal)
    }

    private func unselectButton(button: UIButton) {
        button.layer.backgroundColor = Colors.lightGreyColor.color.cgColor
        button.setTitleColor(UIColor.black, for: .normal)
    }

    private func configureChatButtonAccordingToState(state: CourseState) {
        chatButton.isHidden = state != .booked
    }
}
