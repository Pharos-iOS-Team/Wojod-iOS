// Copyright © 2021 Pharos Solutions. All rights reserved.

import AVKit
import Cosmos
import HandyUIKit

protocol CourseDetailsInfoHeaderDelegate: AnyObject {
    func showDetails()
    func showMaterials()
    func showReviews()
    func goToChat()
    func dismissView()
    func playCourseVideo(playerController: AVPlayerViewController)
}

struct CourseDetailsInfoModel {
    var courseTitle: String?
    var teacherName: String?
    var batchName: String?
    var image: String?
    var video: Media?
    var description: String?
    var price: String?
    var numberOfReviews: String?
    var rating: Double?
    var shouldHideMaterials: Bool
    var buttonSelected: ActiveScreen
    var state: CourseState
    var lessonsUnreadCount: Int?
    var materialsUnreadCount: Int?
    weak var delegate: CourseDetailsInfoHeaderDelegate?
}

class CourseDetailsInfoHeaderView: UIView, NibLoadable {
    static let imageHeight: CGFloat = 320

    @IBOutlet private var detailsButton: UIButton! {
        didSet {
            detailsButton.setTitle(L10n.CourseDetails.Main.details)
        }
    }
    @IBOutlet private var materialsButton: UIButton! {
        didSet {
            materialsButton.setTitle(L10n.CourseDetails.Main.materials)
        }
    }
    @IBOutlet private var reviewsButton: UIButton! {
        didSet {
            reviewsButton.setTitle(L10n.CourseDetails.Main.reviews)
        }
    }
    @IBOutlet private var detailsBadge: UIImageView!
    @IBOutlet private var materialsBadge: UIImageView!
    @IBOutlet private var backButton: UIButton! {
        didSet {
            backButton.setImage(Images.localizedWhiteBackButton)
        }
    }
    @IBOutlet private var playButton: UIButton!

    @IBOutlet private var batchLabel: UITagLabel!
    @IBOutlet private var mainBackgroundView: UIView!
    @IBOutlet private var mainView: UIView!
    @IBOutlet private var mediaContainerView: UIView!
    @IBOutlet private var courseTitle: UILabel!
    @IBOutlet private var teacherNameLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var numberOfReviewsLabel: UILabel!
    @IBOutlet private var priceLabel: UILabel!
    @IBOutlet private var courseImageView: UIImageView!
    @IBOutlet private var ratingView: CosmosView! {
        didSet {
            ratingView.semanticContentAttribute = Language.semanticContent
            ratingView.settings.fillMode = .precise
            ratingView.settings.starMargin = 1
            ratingView.settings.starSize = 20
        }
    }
    @IBOutlet private var chatButton: UIButton!
    @IBOutlet private var numberOfViewLabel: UILabel! {
        didSet {
            numberOfViewLabel.text = L10n.CourseDetails.CourseReview.reviews
        }
    }

    weak var delegate: CourseDetailsInfoHeaderDelegate?
    var video: Media?
    var videoURL: String?

    func prepareImmersiveStyle() {
        backButton.isHidden = true
        courseImageView.contentMode = .scaleAspectFit
        courseImageView.clipsToBounds = true
        mediaContainerView.clipsToBounds = true
    }

    func applyStretchEffect(offset: CGFloat) {
        guard offset < 0 else {
            courseImageView.transform = .identity
            return
        }
        let scale = 1 + abs(offset) / 220
        courseImageView.transform = CGAffineTransform(scaleX: scale, y: scale)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        courseTitle.preferredMaxLayoutWidth = courseTitle.bounds.width
        descriptionLabel.preferredMaxLayoutWidth = descriptionLabel.bounds.width
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        try? loadFromNib()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        try? loadFromNib()
    }

    @IBAction private func didTapDetails(_ sender: Any) {
        configureButtonSelected(buttonSelected: .details)
        delegate?.showDetails()
    }

    @IBAction private func didTapMaterials(_ sender: Any) {
        configureButtonSelected(buttonSelected: .materials)
        delegate?.showMaterials()
    }

    @IBAction private func didTapReviews(_ sender: Any) {
        configureButtonSelected(buttonSelected: .reviews)
        delegate?.showReviews()
    }

    @IBAction private func didTapPlay(_ sender: Any) {
        playButton.isHidden = true
        let courseVideoUrl = video?.fileUrl ?? ""
        guard let videoURL = URL(string: "\(AppEnvironment.baseURL)" + courseVideoUrl) else { return }
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

    @IBAction private func didTapBack(_ sender: Any) {
        delegate?.dismissView()
    }

    func configure(model: CourseDetailsInfoModel) {
        courseTitle.text = model.courseTitle
        teacherNameLabel.text = model.teacherName
        batchLabel.text = model.batchName
        descriptionLabel.text = model.description
        descriptionLabel.preferredMaxLayoutWidth = UIScreen.main.bounds.width - 40
        numberOfReviewsLabel.text = model.numberOfReviews
        courseImageView.kf.setImage(
            with: AppEnvironment.baseURL.appendingPathComponent(model.image ?? ""),
            placeholder: Images.imagePlaceHolder.image
        )
        priceLabel.text = model.price
        materialsButton.isHidden = model.shouldHideMaterials
        configureChatButtonAccordingToState(state: model.state)
        video = model.video
        playButton.isHidden = video?.fileUrl == nil || video?.fileUrl?.isEmpty ?? true || video?.fileUrl?.contains("youtu.be") ?? false
        setRating(model.rating ?? .zero)
        configureButtonSelected(buttonSelected: model.buttonSelected)
        configureLessonBadge(shouldHide: model.lessonsUnreadCount == 0)
        configureMaterialsBadge(shouldHide: model.materialsUnreadCount == 0)
        delegate = model.delegate
    }

    private func configureLessonBadge(shouldHide: Bool) {
        detailsBadge.isHidden = shouldHide
    }

    private func configureMaterialsBadge(shouldHide: Bool) {
        materialsBadge.isHidden = shouldHide
    }

    private func configureButtonSelected(buttonSelected: ActiveScreen) {
        [detailsButton, materialsButton, reviewsButton].compactMap { $0 }.forEach { unselectButton(button: $0) }
        switch buttonSelected {
        case .details:
            selectButton(button: detailsButton)
        case .materials:
            selectButton(button: materialsButton)
        case .reviews:
            selectButton(button: reviewsButton)
        }
    }

    private func setRating(_ rating: Double) {
        ratingView.rating = rating
    }

    private func selectButton(button: UIButton) {
        UIView.animate(withDuration: 0.25) {
            button.layer.backgroundColor = Colors.lightAccentColor.color.cgColor
            button.setTitleColor(Colors.sendButtonColor.color, for: .normal)
        }
    }

    private func unselectButton(button: UIButton) {
        UIView.animate(withDuration: 0.25) {
            button.layer.backgroundColor = Colors.lightGreyColor.color.cgColor
            button.setTitleColor(UIColor.black, for: .normal)
        }
    }

    private func configureChatButtonAccordingToState(state: CourseState) {
        chatButton.isHidden = state != .booked
    }
}
