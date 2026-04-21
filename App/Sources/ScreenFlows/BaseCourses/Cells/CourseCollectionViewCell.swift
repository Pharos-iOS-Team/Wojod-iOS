// Copyright © 2021 Pharos Solutions. All rights reserved.

import AVKit
import Cosmos
import Kingfisher
import UIKit

protocol ViewCourseDetailsDelegate: AnyObject {
    func showCourseDetails(for course: Course?, with teacherNameIndex: Int)
}

protocol ViewReceiptDelegate: AnyObject {
    func displayReceipt(_ receipt: Receipt)
}

class CourseCollectionViewCell: UICollectionViewCell {
    // MARK: - IBOutlets

    @IBOutlet private var badgeImageView: UIImageView! {
        didSet {
            badgeImageView.isHidden = true
        }
    }
    @IBOutlet private var courseContentView: UIView! {
        didSet {
            courseContentView.layer.cornerRadius = UIConstants.slightCornerRadius
        }
    }
    @IBOutlet private var imageView: UIImageView! {
        didSet {
            imageView.layer.cornerRadius = UIConstants.slightCornerRadius
        }
    }
    @IBOutlet private var viewButton: UIButton! {
        didSet {
            viewButton.layer.cornerRadius = UIConstants.slightCornerRadius
            viewButton.setTitle(L10n.Home.view)
        }
    }
    @IBOutlet private var playButton: UIButton! {
        didSet {
            playButton.isHidden = true
        }
    }
    @IBOutlet private var activityIndicator: UIActivityIndicatorView! {
        didSet {
            activityIndicator.hidesWhenStopped = true
        }
    }
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var priceLabel: UILabel!
    @IBOutlet private var ratingView: CosmosView! {
        didSet {
            ratingView.semanticContentAttribute = Language.semanticContent
            ratingView.settings.fillMode = .precise
            ratingView.settings.starMargin = 1
            ratingView.settings.starSize = 15
            ratingView.isUserInteractionEnabled = false
        }
    }

    // MARK: - Private Properties

    private var course: Course?
    private var isMyCourses = Bool()
    private var player: AVPlayer?

    // MARK: - Public Properties

    internal var playVideo: (() -> Void)?
    internal weak var delegate: ViewCourseDetailsDelegate?
    internal weak var viewReceiptDelegate: ViewReceiptDelegate?
    internal var teacherNameIndex: Int?

    // MARK: - IBActions

    @IBAction private func didTapPlayVideo(_ sender: UIButton) {
        self.playVideo?()
    }

    @IBAction private func didTapViewCourse(_ sender: UIButton) {
        delegate?.showCourseDetails(for: course, with: teacherNameIndex ?? 0)
    }

    // MARK: - Lifecycle

    override func prepareForReuse() {
        super.prepareForReuse()
        player?.pause()
        player?.replaceCurrentItem(with: nil)
        player = nil

        imageView.kf.cancelDownloadTask()
        imageView.image = nil
        imageView.subviews.forEach { $0.removeFromSuperview() }
        imageView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }

        ratingView.rating = .zero
        playButton.isHidden = true
        activityIndicator.stopAnimating()

        course = nil
        playVideo = nil
    }

    // MARK: - Private Functions

    private func configureRatingStars(_ rating: Double?) {
        ratingView.rating = rating ?? .zero
    }

    private func configureActionButtonAccordingToState() {
        if course?.reservationState == "pending" {
            viewButton.setTitle(L10n.Home.pending)
            viewButton.layer.backgroundColor = Colors.orange.color.cgColor
        } else if course?.reservationState == "approved" {
            viewButton.setTitle(L10n.Quizzes.open)
            viewButton.layer.backgroundColor = Colors.green.color.cgColor
        } else {
            viewButton.setTitle(L10n.Home.view)
            viewButton.layer.backgroundColor = Colors.sendButtonColor.color.cgColor
        }
    }

    private func coursePrice() -> String {
        guard !isTestingAccount() else { return "" }

        if course?.price == nil || course?.price?.isEmpty ?? true {
            return L10n.Home.Course.returnToTeacher
        } else {
            return "\(L10n.Home.Course.price) \(course?.price ?? "")"
        }
    }

    private func configureBadge() {
        if isMyCourses && course?.reservationState == "approved" {
            if course?.lessonsUnreadCount ?? 0 > 0 || course?.materialsUnreadCount ?? 0 > 0 {
                badgeImageView.isHidden = false
            } else {
                badgeImageView.isHidden = true
            }
        }
    }

    // MARK: - Public Functions

    func configure(with course: Course?, isMyCourses: Bool) {
        self.course = course
        self.isMyCourses = isMyCourses
        titleLabel.text = course?.name
        priceLabel.text = coursePrice()
        activityIndicator.startAnimating()
        if let url = URL(string: "\(AppEnvironment.baseURL)\(course?.media?.fileUrl ?? "")") {
            imageView.kf.setImage(with: url) { _ in
                self.activityIndicator.stopAnimating()
            }
        }
        playButton.isHidden = course?.video?.fileUrl == nil || course?.video?.fileUrl?.isEmpty ?? true
        configureRatingStars(course?.rating ?? 0.0)
        configureActionButtonAccordingToState()
        configureBadge()
    }

    func configureVideo(with url: String) {
        playButton.isHidden = true
        let videoURL = URL(string: "\(AppEnvironment.baseURL)" + url)
        player = AVPlayer(url: videoURL!)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.imageView.bounds
        self.imageView.layer.addSublayer(playerLayer)
        player?.play()
    }

    func stopVideoIfTheresAnyPlaying() {
        guard player != nil else { return }
        player?.pause()
        imageView.subviews.forEach { $0.removeFromSuperview() }
        imageView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
    }
}
