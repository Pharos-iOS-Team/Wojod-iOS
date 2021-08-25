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
    @IBOutlet private var questionStateLabel: UILabel!
    @IBOutlet private var questionCommentLabel: UILabel!
    
    private let commentBackgroundAlpha: CGFloat = 0.11

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
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
            setupView(title: "assignment.correctTitle".localiz(), color: Colors.green.color)
        case .incorrect:
            setupView(title: "assignment.incorrectTitle".localiz(), color: .red)
        case .notReviewed:
            setupView(title: "assignment.notReviewedTitle".localiz(), color: Colors.sendButtonColor.color)
        case .needsImprovement:
            setupView(title: "assignment.needsImprovementTitle".localiz(), color: .orange)
        }
    }

    private func setupView(title: String, color: UIColor) {
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
    }

    private func handleTeacherGradeSelection(teacherSelction: AssessmentQuestion.AnswerState?) {
        switch teacherSelction {
        case .correct:
            questionStateLabel.text = "assignment.correctTitle".localiz()
            questionStateLabel.textColor = Colors.green.color
        case .incorrect:
            questionStateLabel.text = "assignment.incorrectTitle".localiz()
            questionStateLabel.textColor = .red
        default:
            questionStateLabel.text = "assignment.questionIsPending".localiz()
            questionStateLabel.textColor = Colors.sendButtonColor.color
        }
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
