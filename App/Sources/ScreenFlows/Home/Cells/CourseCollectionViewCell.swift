// Copyright © 2021 Pharos Solutions. All rights reserved.

import AVKit
import UIKit

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
        }
    }
    @IBOutlet private var playButton: UIButton! {
        didSet {
            playButton.isHidden = true
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

    internal var playVideo: (() -> Void)?

    // MARK: - IBActions

    @IBAction private func didTapPlayVideo(_ sender: UIButton) {
        self.playVideo!()
    }

    // MARK: - Private Functions

    private func getImage(from url: String) -> UIImage? {
        let imageURL = Environment.baseURLString + url
        guard let url = URL(string: imageURL), let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
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

    // MARK: - Public Functions

    func configure(with course: Course?) {
        titleLabel.text = course?.name
        priceLabel.text = "EGP \(course?.price ?? "")"
        imageView.image = getImage(from: course?.media?.thumbnailUrl ?? "")
        playButton.isHidden = course?.video == nil
        configureRatingStars(course?.rating)
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
