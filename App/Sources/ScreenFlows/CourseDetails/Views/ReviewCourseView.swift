// Copyright © 2021 Pharos Solutions. All rights reserved.

import Cosmos
import UIKit

protocol ReviewCourseViewDelegate: AnyObject {
    func didTapSendButton(courseReview: CourseReview)
    func didTapSkipButton()
}

class ReviewCourseView: UIView {
    // MARK: - IBOutlets

    @IBOutlet private var courseReviewTitleTextField: UITextField! {
        didSet {
            courseReviewTitleTextField.placeholder = L10n.CourseDetails.CourseReview.describeCourse
            courseReviewTitleTextField.textAlignment = Language.textAlignment
            courseReviewTitleTextField.addTarget(self, action: #selector(self.edited), for: .editingChanged)
        }
    }
    @IBOutlet private var courseReviewCommentTextField: UITextField! {
        didSet {
            courseReviewCommentTextField.textAlignment = Language.textAlignment
            courseReviewCommentTextField.addTarget(self, action: #selector(self.edited), for: .editingChanged)
        }
    }
    @IBOutlet private var sendButton: UIButton! {
        didSet {
            sendButton.layer.cornerRadius = UIConstants.cornerRadius
            sendButton.isEnabled = false
            sendButton.backgroundColor = Colors.labelGreyColor.color
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
    @IBOutlet private var starRatingsView: CosmosView! {
        didSet {
            starRatingsView.semanticContentAttribute = Language.semanticContent
            starRatingsView.settings.fillMode = .precise
            starRatingsView.settings.starMargin = 2
            starRatingsView.settings.minTouchRating = 0.5
            starRatingsView.rating = 0.5
            starRatingsView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(edited)))
        }
    }

    // MARK: - Public Properties

    internal weak var delegate: ReviewCourseViewDelegate?

    // MARK: - IBActions

    @IBAction private func didTapSendButton(_ sender: UIButton) {
        self.removeFromSuperview()
        delegate?.didTapSendButton(courseReview: retrieveCourseReview())
    }

    @IBAction private func didTapSkipRatingButton(_ sender: UIButton) {
        self.removeFromSuperview()
        delegate?.didTapSkipButton()
    }

    // MARK: - Private Functions

    private func retrieveCourseReview() -> CourseReview {
        return CourseReview(
            title: courseReviewTitleTextField.text,
            rating: starRatingsView.rating,
            comment: courseReviewCommentTextField.text
        )
    }

    @objc
    private func edited() {
        if !courseReviewTitleTextField.isEmpty && starRatingsView.rating != 0 {
            sendButton.isEnabled = true
            sendButton.backgroundColor = Colors.sendButtonColor.color
        } else {
            sendButton.isEnabled = false
            sendButton.backgroundColor = Colors.labelGreyColor.color
        }
    }
}
