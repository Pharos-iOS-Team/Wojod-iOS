//
//  AssignmentQuestionStateView.swift
//  School
//
//  Created by Rami Saeed on 9/14/20.
//  Copyright © 2020 Pharos Solutions GmbH. All rights reserved.
//

// swiftlint:disable all

import UIKit

class AssignmentQuestionStateView: UIView {
    var trueButtonTappedHandler: (() -> Void)?
    var falseButtonTappedHandler: (() -> Void)?
    @IBOutlet private var stackView: UIStackView!
    @IBOutlet private var trueAndFalseStackView: UIStackView!
    @IBOutlet private var trueButton: UIButton!
    @IBOutlet private var trueContainerView: UIView!
    @IBOutlet private var falseButton: UIButton!
    @IBOutlet private var falseContainerView: UIView!
    @IBOutlet private var questionStateLabel: UILabel!
    @IBOutlet private var questionCommentLabel: UILabel!
    
    private let commentBackgroundAlpha: CGFloat = 0.11

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
        falseButton.setImage(Images.closeBold.image.withRenderingMode(.alwaysTemplate), for: .normal)
        trueButton.setImage(Images.correctBold.image.withRenderingMode(.alwaysTemplate), for: .normal)
    }

    @IBAction private func trueButtonTapped() {
        trueButtonTappedHandler?()
        teacherSelect(selection: true)
        questionStateLabel.fadeTransition(0.4)
    }

    @IBAction private func falseButtonTapped() {
        teacherSelect(selection: false)
        falseButtonTappedHandler?()
        questionStateLabel.fadeTransition(0.4)
    }
    
    class func instantiate() -> AssignmentQuestionStateView? {
        UINib(nibName: Nib.assignmentQuestionStateView.rawValue, bundle: nil).instantiate(withOwner: nil, options: nil).first as? AssignmentQuestionStateView
    }

    func setQuestionComment(_ text: String?, _ state: AssessmentQuestion.AnswerState, questionType: AssessmentQuestion.QuestionType, isAnswered: Bool, teacherSelction: AssessmentQuestion.AnswerState?) {
        if questionType == .freeText, isAnswered, teacherSelction == nil {
            stackView.spacing = 5
            questionCommentLabel.font = UIFont(font: FontFamily.Inter.regular, size: 11)
            questionCommentLabel.text = "assignment.notGraded".localiz()
            questionCommentLabel.textAlignment = "assignment.notGraded".localiz().dominantTextAlignment
            return
        }
        guard let comment = text, comment.isValid else {
            questionCommentLabel.text = nil
            stackView.spacing = 0
            return
        }
        stackView.spacing = 5
        questionCommentLabel.font = UIFont(font: FontFamily.Inter.regular, size: 11)
        questionCommentLabel.text = comment
        questionCommentLabel.textAlignment = Language.textAlignment
    }

    func configureAnswerState(
        _ state: AssessmentQuestion.AnswerState,
        teacherSelction: AssessmentQuestion.AnswerState?,
        questionType: AssessmentQuestion.QuestionType,
        isAnswered: Bool
    ) {
        if questionType == .freeText, isAnswered {
            setupViewForTeacherReviewStateOnly(teacherSelction: teacherSelction)
            return
        }
        switch state {
        case .correct:
            setupView(title: "assignment.correctTitle".localiz(), color: .green)
        case .incorrect:
            setupView(title: "assignment.incorrectTitle".localiz(), color: .red)
        case .notReviewed:
            setupView(title: "assignment.notReviewedTitle".localiz(), color: Colors.sendButtonColor.color)
        case .needsImprovement:
            setupView(title: "assignment.needsImprovementTitle".localiz(), color: .orange)
        }
    }

    private func setupView(title: String, color: UIColor) {
        trueAndFalseStackView.isHidden = true
        questionStateLabel.text = title
        questionStateLabel.textColor = color
        backgroundColor = color.withAlphaComponent(commentBackgroundAlpha)
        layer.borderWidth = 0
    }

    private func setupViewForTeacherReviewStateOnly(teacherSelction: AssessmentQuestion.AnswerState?) {
        backgroundColor = .white
        layer.borderWidth = 2
        layer.borderColor = Colors.superLightGrey.color.cgColor
        layer.cornerRadius = 10
        handleTeacherGradeSelection(teacherSelction: teacherSelction)
        configureTrueAndFalseStackView(teacherSelction: teacherSelction)
    }

    private func handleTeacherGradeSelection(teacherSelction: AssessmentQuestion.AnswerState?) {
        switch teacherSelction {
        case .correct:
            questionStateLabel.text = "assignment.correctTitle".localiz()
            questionStateLabel.textColor = .green
        case .incorrect:
            questionStateLabel.text = "assignment.incorrectTitle".localiz()
            questionStateLabel.textColor = .red
        default:
            questionStateLabel.text = "assignment.questionIsPending".localiz()
            questionStateLabel.textColor = Colors.sendButtonColor.color
        }
    }

    private func configureTrueAndFalseStackView(teacherSelction: AssessmentQuestion.AnswerState?) {
        trueAndFalseStackView.isHidden = false
        trueContainerView.layer.cornerRadius = 4
        falseContainerView.layer.cornerRadius = 4
        switch teacherSelction {
        case .correct:
            teacherSelect(selection: true)
        case .incorrect:
            teacherSelect(selection: false)
        default:
            teacherSelect(selection: nil)
        }
    }

    private func teacherSelect(selection: Bool?) {
        guard let selection = selection else {
            setReviewButtonsColor(trueColor: Asset.Colors.darkGreyColor.color, falseColor: Asset.Colors.darkGreyColor.color)
            return
        }
        if selection {
            UIView.animate(withDuration: 0.2, delay: 0.0, options: [.curveEaseIn]) {
                self.setReviewButtonsColor(trueColor: .green, falseColor: Asset.Colors.darkGreyColor.color)
            }
        } else {
            UIView.animate(withDuration: 0.2, delay: 0.0, options: [.curveEaseIn]) {
                self.setReviewButtonsColor(trueColor: Asset.Colors.darkGreyColor.color, falseColor: .red)
            }
        }
    }
    
    private func setReviewButtonsColor(trueColor: UIColor, falseColor: UIColor) {
        self.trueButton.tintColor = trueColor
        self.trueContainerView.backgroundColor = trueColor.withAlphaComponent(0.35)
        self.falseButton.tintColor = falseColor
        self.falseContainerView.backgroundColor = falseColor.withAlphaComponent(0.35)
    }
}

extension UIView {
    func fadeTransition(_ duration:CFTimeInterval) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name:
            CAMediaTimingFunctionName.easeInEaseOut)
        animation.type = CATransitionType.fade
        animation.duration = duration
        layer.add(animation, forKey: CATransitionType.fade.rawValue)
    }
}
