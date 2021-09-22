//  Copyright © 2020 Pharos Solutions GmbH. All rights reserved.

// swiftlint:disable all

import UIKit
import LanguageManager_iOS

protocol AssessmentFreeTextDelegate: AnyObject {
    func didTapAttach(_ sender: UIButton)
    func didTapDeleteAttachment()
    func didOpenAttachment()
}

class AssessmentFreeTextTableViewCell: UITableViewCell {
    @IBOutlet private var containerView: UIView!
    @IBOutlet private var yourAnswerLabel: UILabel!
    @IBOutlet private var answerTextView: UITextView!
    @IBOutlet private var attachmentImageView: UIImageView!
    @IBOutlet private var attachFileButton: UIButton!
    @IBOutlet private var cancelUploadButton: UIButton!
    @IBOutlet private var attachmentImageViewWidthConstraint: NSLayoutConstraint!

    private weak var delegate: AssessmentFreeTextDelegate?
    private let attachmentImageViewWidth: CGFloat = 60
    private let commentBackgroundAlpha: CGFloat = 0.11
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
        addAttachmentGestureRecognizer()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        answerTextView.textAlignment = .natural
        // setUploadProgressViewHidden(true)
    }
    
    func setDelegate(_ delegate: AssessmentFreeTextDelegate) {
        self.delegate = delegate
    }

    func setTextViewDelegate(_ delegate: UITextViewDelegate) {
        answerTextView.delegate = delegate
    }

    func configure(
        with answer: String?,
        alignment: NSTextAlignment,
        attachmentURLString: String?,
        currentProgress: Double
    ) {
        answerTextView.text = answer
        configureAttachment(attachmentURLString)
        configureTextViewAlignment(alignment: alignment)
        setProgress(CGFloat(currentProgress))
    }

    func configureAnswer(
        isAnswered: Bool,
        isCorrectAnswer: Bool?,
        module: AssessmentsOverViewViewModel.Module,
        assignmentAnswerState: AssessmentQuestion.AnswerState,
        question: AssessmentQuestion?,
        isComment: Bool?
    ) {
        configureIsAnswered(isAnswered)
        switch module {
        case .quizzes:
            configureCorrectAnswer(isAnswered, isCorrectAnswer, question, isComment ?? false)
        case .assignments:
            configureAssignmentAnswerState(state: assignmentAnswerState)
        default:
            return
        }
    }

    func configureAttachment(_ attachmentURLString: String?) {
        setAttachmentHidden(attachmentURLString?.isValid != true)
    }

    func setProgress(_ progress: CGFloat) {
        guard progress != 1.0, progress != 0.0 else {
            // setUploadProgressViewHidden(true)
            setAttachmentUserInteractionEnabled(true)
            // uploadProgressView.updateProgress(0.0)
            return
        }
        if attachmentImageView.isHidden { setAttachmentHidden(false) }
        // setUploadProgressViewHidden(false)
        setAttachmentUserInteractionEnabled(false)
        // uploadProgressView.updateProgress(progress)
    }

    private func configureUI() {
        selectionStyle = .none
        answerTextView.textAlignment = .left
        answerTextView.backgroundColor = .clear
        containerView.layer.cornerRadius = 10
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = Asset.Colors.sendButtonColor.color.cgColor.copy(alpha: 0.2)
        cancelUploadButton.setFrameShape(.circular)
        cancelUploadButton.layer.borderColor = Asset.Colors.sendButtonColor.color.cgColor
        cancelUploadButton.layer.borderWidth = 2
        // uploadProgressView.innerTintColor = .clear
        // uploadProgressView.trackTintColor = Asset.Colors.appBlue.color.withAlphaComponent(0.3)
        // uploadProgressView.progressTintColor = Asset.Colors.appBlue.color
        setAttachmentUserInteractionEnabled(true)
    }

    private func configureIsAnswered(_ isAnswered: Bool) {
        if isAnswered {
            cancelUploadButton.isHidden = true
            attachFileButton.isHidden = true
            answerTextView.isUserInteractionEnabled = false
        }
    }

    private func configureCorrectAnswer(_ isAnswered: Bool, _ isCorrectAnswer: Bool?, _ question: AssessmentQuestion?, _ isComment: Bool) {
        guard let question = question, isAnswered else { return }
        switch question.studentMark {
        case Double.zero:
            containerView.backgroundColor = UIColor.red.withAlphaComponent(0.1)
            containerView.layer.borderColor = UIColor.red.cgColor
        case question.mark:
            containerView.backgroundColor = Colors.green.color.withAlphaComponent(0.2)
            containerView.layer.borderColor = Colors.green.color.cgColor
        case nil:
            answerTextView.backgroundColor = .clear
            containerView.backgroundColor = .clear
            containerView.layer.borderColor = Asset.Colors.sendButtonColor.color.cgColor.copy(alpha: 0.2)
        default:
            containerView.backgroundColor = UIColor.orange.withAlphaComponent(0.11)
            containerView.layer.borderColor = UIColor.orange.cgColor
        }
        handleTitleLabel(isComment: isComment) 
    }

    private func handleTitleLabel(isComment: Bool) {
        if isComment {
            yourAnswerLabel.text = "quizzes.questionComment".localiz()
        } else {
            yourAnswerLabel.text = "quizzes.yourAnswer".localiz()
        }
    }

    private func configureTextViewAlignment(alignment: NSTextAlignment) {
        answerTextView.textAlignment = alignment
    }

    private func addAttachmentGestureRecognizer() {
        attachmentImageView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(openAttachment))
        )
    }

//    private func setUploadProgressViewHidden(_ shouldHide: Bool) {
//        uploadProgressView.isHidden = shouldHide
//    }

    private func setAttachmentHidden(_ shouldHide: Bool) {
        attachmentImageViewWidthConstraint.constant = shouldHide ? 0 : attachmentImageViewWidth
        attachmentImageView.isHidden = shouldHide
        cancelUploadButton.isHidden = shouldHide
    }

    private func setAttachmentUserInteractionEnabled(_ isEnabled: Bool) {
        attachmentImageView.isUserInteractionEnabled = isEnabled
    }

    private func configureAssignmentAnswerState(state: AssessmentQuestion.AnswerState) {
        switch state {
        case .incorrect:
            containerView.backgroundColor = UIColor.red.withAlphaComponent(commentBackgroundAlpha)
            containerView.layer.borderColor =  UIColor.red.cgColor
        case .needsImprovement:
            containerView.backgroundColor = UIColor.orange.withAlphaComponent(commentBackgroundAlpha)
            containerView.layer.borderColor = UIColor.orange.cgColor
        case .notReviewed:
            containerView.backgroundColor = .clear
            answerTextView.backgroundColor = .clear
            containerView.layer.borderColor = Asset.Colors.sendButtonColor.color.cgColor.copy(alpha: 0.2)
        case .correct:
            containerView.backgroundColor = Colors.green.color.withAlphaComponent(commentBackgroundAlpha)
            containerView.layer.borderColor = Colors.green.color.cgColor
        }
    }
}

// MARK: - IBActions
extension AssessmentFreeTextTableViewCell {
    @IBAction private func attach(_ sender: UIButton) {
        delegate?.didTapAttach(sender)
    }
    
    @IBAction private func deleteAttachment(_ sender: UIButton) {
        setAttachmentHidden(true)
        // setUploadProgressViewHidden(true)
        delegate?.didTapDeleteAttachment()
    }
}

// MARK: - Selectors
extension AssessmentFreeTextTableViewCell {
    @objc private func openAttachment() {
        delegate?.didOpenAttachment()
    }
}
