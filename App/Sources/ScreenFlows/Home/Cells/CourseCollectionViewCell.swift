// Copyright © 2021 Pharos Solutions. All rights reserved.

import AVKit
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
    @IBOutlet private var seeReceiptButton: UIButton! {
        didSet {
            seeReceiptButton.layer.cornerRadius = UIConstants.slightCornerRadius
            seeReceiptButton.setTitle(L10n.Home.Course.seeReceipt)
        }
    }
    @IBOutlet private var activityIndicator: UIActivityIndicatorView! {
        didSet {
            activityIndicator.hidesWhenStopped = true
        }
    }
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var priceLabel: UILabel!
    @IBOutlet private var firstRatingStar: UIImageView!
    @IBOutlet private var secondRatingStar: UIImageView!
    @IBOutlet private var thirdRatingStar: UIImageView!
    @IBOutlet private var fourthRatingStar: UIImageView!
    @IBOutlet private var fifthRatingStar: UIImageView!

    // MARK: - Private Properties

    private let dimmedStar: UIImage = Images.star.image
    private let filledStar: UIImage = Images.filledStar.image
    private var course: Course?
    private var isMyCourses = Bool()

    // MARK: - Public Properties

    internal var playVideo: (() -> Void)?
    internal weak var delegate: ViewCourseDetailsDelegate?
    internal weak var viewReceiptDelegate: ViewReceiptDelegate?
    internal var teacherNameIndex: Int?

    // MARK: - IBActions

    @IBAction private func didTapPlayVideo(_ sender: UIButton) {
        self.playVideo!()
    }

    @IBAction private func didTapViewCourse(_ sender: UIButton) {
        delegate?.showCourseDetails(for: course, with: teacherNameIndex ?? 0)
    }

    @IBAction private func didTapSeeReceipt(_ sender: UIButton) {
        viewReceiptDelegate?.displayReceipt(course?.receipt ?? Receipt())
    }

    // MARK: - Lifecycle

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }

    // MARK: - Private Functions

    private func loadImage(from url: String, completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global().async {
            let imageURL = Environment.baseURLString + url
            guard let url = URL(string: imageURL), let data = try? Data(contentsOf: url) else { return }
            completion(UIImage(data: data))
        }
    }

    // swiftlint:disable function_body_length
    private func configureRatingStars(_ rating: Double?) {
        var ratingNumber = rating
        ratingNumber?.round()

        switch ratingNumber {
        case 1:
            firstRatingStar.image = filledStar
        case 2:
            firstRatingStar.image = filledStar
            secondRatingStar.image = filledStar
        case 3:
            firstRatingStar.image = filledStar
            secondRatingStar.image = filledStar
            thirdRatingStar.image = filledStar
        case 4:
            firstRatingStar.image = filledStar
            secondRatingStar.image = filledStar
            thirdRatingStar.image = filledStar
            fourthRatingStar.image = filledStar
        case 5:
            firstRatingStar.image = filledStar
            secondRatingStar.image = filledStar
            thirdRatingStar.image = filledStar
            fourthRatingStar.image = filledStar
            fifthRatingStar.image = filledStar
        default:
            return
        }
    }

    private func configureVisibilityOfSeeReceiptButton() {
        if isMyCourses && course?.reservationState == "pending" {
            seeReceiptButton.isHidden = false
        } else {
            seeReceiptButton.isHidden = true
        }
    }

    private func coursePrice() -> String {
        if course?.price == nil || course?.price?.isEmpty ?? true {
            return L10n.Home.Course.returnToTeacher
        } else {
            return "\(L10n.Home.Course.price) \(course?.price ?? "")"
        }
    }

    // MARK: - Public Functions

    func configure(with course: Course?, isMyCourses: Bool) {
        self.course = course
        self.isMyCourses = isMyCourses
        titleLabel.text = course?.name
        priceLabel.text = coursePrice()
        activityIndicator.startAnimating()
        if let url = URL(string: "\(Environment.baseURL)\(course?.media?.fileUrl ?? "")") {
            imageView.kf.setImage(with: url) { _ in
                self.activityIndicator.stopAnimating()
            }
        }
        playButton.isHidden = course?.video == nil
        configureRatingStars(course?.rating)
        configureVisibilityOfSeeReceiptButton()
    }

    func configureVideo(with url: String) {
        playButton.isHidden = true
        let videoURL = URL(string: "\(Environment.baseURL)" + url)
        let player = AVPlayer(url: videoURL!)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.imageView.bounds
        self.imageView.layer.addSublayer(playerLayer)
        player.play()
    }
}
