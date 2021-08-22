// Copyright © 2020 Pharos Solutions GmbH. All rights reserved.

// swiftlint:disable all

import UIKit

class AssessmentDetailQuestionNumberCollectionViewCell: UICollectionViewCell {
    // MARK: - Outlets

    @IBOutlet private var containerView: UIView! {
        didSet {
            containerView.setFrameShape(.circular)
        }
    }
    @IBOutlet private var questionNumberLabel: UILabel! {
        didSet {
            questionNumberLabel.numberOfLines = 1
        }
    }

    // MARK: - Private properties

    private let defaultLightColorAlpha: CGFloat = 0.11
    private let answerLightColorAlpha: CGFloat = 0.3
    private var textColor: UIColor = .black {
        didSet {
            questionNumberLabel.textColor = textColor
        }
    }

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        clipsToBounds = true
        containerView.backgroundColor = Asset.Colors.sendButtonColor.color.withAlphaComponent(defaultLightColorAlpha)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        setFrameShape(.circular)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        questionNumberLabel.text = nil
        containerView.backgroundColor = Asset.Colors.sendButtonColor.color.withAlphaComponent(defaultLightColorAlpha)
    }

    // MARK: - Public functions

    func configure(
        with questionNumber: Int,
        isSelected: Bool,
        isAnswered: Bool,
        isWrongAnswer: Bool,
        isRightAnswer: Bool,
        question: AssessmentQuestion?
    ) {
        setQuestionNumber(questionNumber)
        textColor = isSelected ? .white : .black
        configureCellColor(isSelected, isAnswered, isWrongAnswer, isRightAnswer, question)
    }

    func configureAssignmentAnswer(with questionNumber: Int, _ state: AssessmentQuestion.AnswerState, isSelected: Bool) {
        setQuestionNumber(questionNumber)
        switch state {
        case .correct:
            markAsRightAnswer()
        case .incorrect:
            markAsWrongAnswer()
        case .needsImprovement:
            markAsNeedsImprovementAnswer()
        case .notReviewed:
            markAsNotReviewedAnswer()
        }
        if isSelected {
            markAsSelectedAnswer()
        }
    }

    // MARK: - Private functions

    private func setQuestionNumber(_ questionNumber: Int) {
        questionNumberLabel.text = NumberFormatter.getFormattedString(fromInt: questionNumber)
    }

    private func configureCellColor(
        _ isSelected: Bool,
        _ isAnswered: Bool,
        _ isWrongAnswer: Bool,
        _ isRightAnswer: Bool,
        _ question: AssessmentQuestion?
    ) {
        if isAnswered {
            markAsAnswered()
        }
        if isAnswered && question?.studentMark != nil || isWrongAnswer || isRightAnswer {
            markAnswer(question, isAnswered)
        }
        if isSelected {
            markAsSelectedAnswer()
        }
    }
    
    private func markAnswer(_ question: AssessmentQuestion?, _ isAnswered: Bool) {
        switch question?.studentMark {
        case Double.zero:
            markAsWrongAnswer()
        case question?.mark where question?.mark != nil:
            markAsRightAnswer()
        case nil where isAnswered:
            markAsAnswered()
        case .some where question?.studentMark ?? 0 < question?.mark ?? 0 && question?.studentMark ?? 0 > 0:
            markAsNeedsImprovementAnswer()
        default:
            markAsNotReviewedAnswer()
        }
    }

    private func markAsRightAnswer() {
        containerView.backgroundColor = Colors.green.color.withAlphaComponent(answerLightColorAlpha)
        textColor = Colors.green.color
    }

    private func markAsWrongAnswer() {
        containerView.backgroundColor = UIColor.red.withAlphaComponent(answerLightColorAlpha)
        textColor = .red
    }

    private func markAsNeedsImprovementAnswer() {
        containerView.backgroundColor = UIColor.orange.withAlphaComponent(defaultLightColorAlpha)
        textColor = .orange
    }

    private func markAsNotReviewedAnswer() {
        containerView.backgroundColor = Asset.Colors.sendButtonColor.color.withAlphaComponent(answerLightColorAlpha)
        textColor = .black
    }

    private func markAsAnswered() {
        containerView.backgroundColor = Asset.Colors.sendButtonColor.color.withAlphaComponent(answerLightColorAlpha)
    }
    
    private func markAsSelectedAnswer() {
        containerView.backgroundColor = Asset.Colors.sendButtonColor.color
        textColor = .white
    }
}
