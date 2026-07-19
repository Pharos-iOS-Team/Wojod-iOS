// Copyright © 2026 Pharos Solutions. All rights reserved.

import Cosmos
import UIKit

class ReviewCourseViewController: UIViewController {
    // MARK: - IBOutlets (Connect to the new File's Owner)
    @IBOutlet private var containerView: UIView!
    @IBOutlet private var courseReviewTitleTextField: UITextField!
    @IBOutlet private var courseReviewCommentTextField: UITextField!
    @IBOutlet private var starRatingsView: CosmosView!
    @IBOutlet private var sendButton: UIButton!
    @IBOutlet private var messageTitleLabel: UILabel!
    @IBOutlet private var rateContentLabel: UILabel!
    @IBOutlet private var skipRatingButton: UIButton!
    @IBOutlet private var sendLabel: UILabel!
    @IBOutlet private var nextIconImageView: UIImageView!

    // MARK: - Properties
    var sendReview: ((CourseReview) async -> Bool)?
    var onComplete: ((Bool) -> Void)?
    var onSkip: (() -> Void)?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupStarRating()
        setupTextFields()
    }

    // MARK: - IBActions
    @IBAction private func didTapSendButton(_ sender: UIButton) {
        let review = CourseReview(
            title: courseReviewTitleTextField.text,
            rating: starRatingsView.rating,
            comment: courseReviewCommentTextField.text
        )
        sendButton.isEnabled = false
        Task {
            let success = await sendReview?(review) ?? false
            await MainActor.run {
                dismiss(animated: true)
                onComplete?(success)
            }
        }
    }

    @IBAction private func didTapSkipRatingButton(_ sender: UIButton) {
        dismiss(animated: true)
        onSkip?()
    }

    private func setupUI() {
        containerView.layer.cornerRadius = UIConstants.cornerRadius
        containerView.addShadow()

        sendButton.layer.cornerRadius = UIConstants.cornerRadius
        sendButton.isEnabled = false
        sendButton.backgroundColor = Colors.labelGreyColor.color

        messageTitleLabel.text = L10n.CourseDetails.CourseReview.messageTitle
        rateContentLabel.text = L10n.CourseDetails.CourseReview.rateContent
        skipRatingButton.setTitle(L10n.CourseDetails.CourseReview.skipRating, for: .normal)
        sendLabel.text = L10n.Login.send
        nextIconImageView.image = Images.localizedNextButton
    }

    private func setupStarRating() {
        starRatingsView.semanticContentAttribute = Language.semanticContent
        starRatingsView.settings.fillMode = .full
        starRatingsView.settings.starMargin = 2
        starRatingsView.settings.minTouchRating = 1
        starRatingsView.rating = 0

        starRatingsView.didFinishTouchingCosmos = { [weak self] _ in
            self?.validateInput()
        }
    }

    private func setupTextFields() {
        courseReviewTitleTextField.placeholder = L10n.CourseDetails.CourseReview.describeCourse
        courseReviewTitleTextField.textAlignment = Language.textAlignment
        courseReviewCommentTextField.textAlignment = Language.textAlignment

        courseReviewTitleTextField.addTarget(self, action: #selector(validateInput), for: .editingChanged)
        courseReviewCommentTextField.addTarget(self, action: #selector(validateInput), for: .editingChanged)
    }

    @objc
    private func validateInput() {
        let isTitleValid = !(courseReviewTitleTextField.text?.isEmpty ?? true)
        let isRatingValid = starRatingsView.rating > 0

        sendButton.isEnabled = isTitleValid && isRatingValid
        sendButton.backgroundColor = sendButton.isEnabled ? Colors.sendButtonColor.color : Colors.labelGreyColor.color
    }
}
