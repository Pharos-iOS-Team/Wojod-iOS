// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit

protocol ReviewCourseViewDelegate: AnyObject {
    func didTapSendButton(courseReview: CourseReview)
    func didTapSkipButton()
}

class ReviewCourseView: UIView {
    // MARK: - IBOutlets

    @IBOutlet private var firstStar: UIButton!
    @IBOutlet private var secondStar: UIButton!
    @IBOutlet private var thirdStar: UIButton!
    @IBOutlet private var fourthStar: UIButton!
    @IBOutlet private var fifthStar: UIButton!
    @IBOutlet private var courseReviewTitleTextField: UITextField! {
        didSet {
            courseReviewTitleTextField.placeholder = L10n.CourseDetails.CourseReview.describeCourse
            courseReviewTitleTextField.textAlignment = Language.textAlignment
        }
    }
    @IBOutlet private var courseReviewCommentTextField: UITextField! {
        didSet {
            courseReviewCommentTextField.textAlignment = Language.textAlignment
        }
    }
    @IBOutlet private var sendButton: UIButton! {
        didSet {
            sendButton.layer.cornerRadius = UIConstants.cornerRadius
        }
    }
    @IBOutlet private var messageTitleLabel: UILabel! {
        didSet {
            messageTitleLabel.text = L10n.CourseDetails.CourseReview.messageTitle
        }
    }
    @IBOutlet private var rateContentLabel: UILabel! {
        didSet {
            rateContentLabel.text = L10n.CourseDetails.CourseReview.rateContent
        }
    }
    @IBOutlet private var skipRatingButton: UIButton! {
        didSet {
            skipRatingButton.setTitle(L10n.CourseDetails.CourseReview.skipRating)
        }
    }
    @IBOutlet private var sendLabel: UILabel! {
        didSet {
            sendLabel.text = L10n.Login.send
        }
    }
    @IBOutlet private var nextIconImageView: UIImageView! {
        didSet {
            nextIconImageView.image = Images.localizedNextButton
        }
    }

    // MARK: - Public Properties

    internal weak var delegate: ReviewCourseViewDelegate?

    // MARK: - Private Properties

    private var rating: Int = 0

    // MARK: - IBActions

    @IBAction private func didTapSendButton(_ sender: UIButton) {
        self.removeFromSuperview()
        delegate?.didTapSendButton(courseReview: retrieveCourseReview())
    }

    @IBAction private func didTapSkipRatingButton(_ sender: UIButton) {
        self.removeFromSuperview()
        delegate?.didTapSkipButton()
    }

    @IBAction private func didTapFirstStar(_ sender: UIButton) {
        rating = 1
        firstStar.setImage(Images.filledStar.image)
        secondStar.setImage(Images.star.image)
        thirdStar.setImage(Images.star.image)
        fourthStar.setImage(Images.star.image)
        fifthStar.setImage(Images.star.image)
    }

    @IBAction private func didTapSecondStar(_ sender: UIButton) {
        rating = 2
        firstStar.setImage(Images.filledStar.image)
        secondStar.setImage(Images.filledStar.image)
        thirdStar.setImage(Images.star.image)
        fourthStar.setImage(Images.star.image)
        fifthStar.setImage(Images.star.image)
    }

    @IBAction private func didTapThirdStar(_ sender: UIButton) {
        rating = 3
        firstStar.setImage(Images.filledStar.image)
        secondStar.setImage(Images.filledStar.image)
        thirdStar.setImage(Images.filledStar.image)
        fourthStar.setImage(Images.star.image)
        fifthStar.setImage(Images.star.image)
    }

    @IBAction private func didTapFourthStar(_ sender: UIButton) {
        rating = 4
        firstStar.setImage(Images.filledStar.image)
        secondStar.setImage(Images.filledStar.image)
        thirdStar.setImage(Images.filledStar.image)
        fourthStar.setImage(Images.filledStar.image)
        fifthStar.setImage(Images.star.image)
    }

    @IBAction private func didTapFifthStar(_ sender: UIButton) {
        rating = 5
        firstStar.setImage(Images.filledStar.image)
        secondStar.setImage(Images.filledStar.image)
        thirdStar.setImage(Images.filledStar.image)
        fourthStar.setImage(Images.filledStar.image)
        fifthStar.setImage(Images.filledStar.image)
    }

    // MARK: - Private Functions

    private func retrieveCourseReview() -> CourseReview {
        return CourseReview(
            title: courseReviewTitleTextField.text,
            rating: rating,
            comment: courseReviewCommentTextField.text
        )
    }
}
