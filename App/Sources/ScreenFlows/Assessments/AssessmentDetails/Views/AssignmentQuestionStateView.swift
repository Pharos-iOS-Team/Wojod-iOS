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

    func configureAnswerState(
        _ state: AnswerState,
        questionType: QuestionType,
        isAnswered: Bool
    ) {
        switch state {
        case .correct:
            setupView(title: L10n.Assignment.correctTitle, color: Colors.green.color)
        case .incorrect:
            setupView(title: L10n.Assignment.incorrectTitle, color: .red)
        case .notReviewed:
            setupView(title: L10n.Assignment.notReviewed, color: Colors.sendButtonColor.color)
        case .needsImprovement:
            setupView(title: L10n.Assignment.needsImprovement, color: .orange)
        }
    }

    private func setupView(title: String, color: UIColor) {
        questionStateLabel.text = title
        questionStateLabel.textColor = color
        backgroundColor = color.withAlphaComponent(commentBackgroundAlpha)
        layer.borderWidth = 0
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
