//  Copyright © 2020 Pharos Solutions GmbH. All rights reserved.

// swiftlint:disable all

import UIKit

class AssessmentDetailOverViewQuestionsTableViewCell: UITableViewCell {
    @IBOutlet private weak var questionNameLabel: UILabel!
    @IBOutlet private weak var numberOfPointsLabel: UILabel! {
        didSet {
            numberOfPointsLabel.adjustsFontSizeToFitWidth = true
        }
    }
    @IBOutlet private weak var questionStatusLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }

    private let markFont = UIFont(font: FontFamily.Inter.regular, size: 14) ?? UIFont.systemFont(ofSize: 14)
    private let statusFont = UIFont(font: FontFamily.Inter.regular, size: 12) ?? UIFont.systemFont(ofSize: 12)

    func configure(assessmentName name: String, numberOfPoints: String, questionStatus: Bool, mark: String, assessmentStatus: AssessmentStatus, questionMarkStatus: QuestionStatus, module: AssessmentsOverViewViewModel.Module, answerStatus: AssessmentQuestion.AnswerState) {
        setQuestionName(name)
        setQuestionStatus(questionStatus, assessmentStatus, module, answerStatus)
        setMarkLabel(assessmentStatus, module, numberOfPoints, mark, questionMarkStatus)
    }

    private func setMarkLabel(_ assessmentStatus: AssessmentStatus, _ module: AssessmentsOverViewViewModel.Module, _ numberOfPoints: String, _ mark: String, _ questionMarkStatus: QuestionStatus) {
        switch module {
        case .quizzes:
            assessmentStatus == .open
                ? numberOfPointsLabel.text = numberOfPoints
                : setQuestionMark(mark, questionMarkStatus)
        case .assignments:
            hideMarkLabel()
        default:
            return
        }
    }

    private func setQuestionMark(_ mark: String, _ questionMarkStatus: QuestionStatus) {
        switch questionMarkStatus {
        case .correct:
            numberOfPointsLabel.textColor = .green
            numberOfPointsLabel.font = markFont
            numberOfPointsLabel.text = mark
        case .wrong:
            numberOfPointsLabel.textColor = .red
            numberOfPointsLabel.font = markFont
            numberOfPointsLabel.text = mark
        case .notGraded:
            numberOfPointsLabel.textColor = Asset.Colors.sendButtonColor.color
            numberOfPointsLabel.font = markFont
            numberOfPointsLabel.text = "quizzes.notGradedYet".localiz()
        case .needsImprovement:
            numberOfPointsLabel.textColor = .orange
            numberOfPointsLabel.font = markFont
            numberOfPointsLabel.text = mark
        }
    }

    private func hideStatusLabel() {
        questionStatusLabel.isHidden = true
    }

    private func hideMarkLabel() {
        numberOfPointsLabel.isHidden = true
    }

    private func setQuestionName(_ text: String) {
        questionNameLabel.text = text
    }
    
    private func setNumberOfPoints(_ text: String) {
        numberOfPointsLabel.text = text
    }
    
    private func setQuestionStatus(_ answered: Bool, _ assessmentStatus: AssessmentStatus, _ module: AssessmentsOverViewViewModel.Module, _ answerStatus: AssessmentQuestion.AnswerState) {
        switch assessmentStatus {
        case .open:
            if answered {
                questionStatusLabel.textColor = .gray
                questionStatusLabel.font = statusFont
                questionStatusLabel.text = "quizzes.answered".localiz()
            } else {
                questionStatusLabel.textColor = .red
                questionStatusLabel.font = statusFont
                questionStatusLabel.text = "quizzes.notAnswered".localiz()
            }
        case .closed where module == .assignments:
            setAssignmentQuestionStatus(answerStatus)
        default:
            hideStatusLabel()
        }
    }

    private func setAssignmentQuestionStatus(_ status: AssessmentQuestion.AnswerState) {
        switch status {
        case .correct:
            questionStatusLabel.textColor = .green
            questionStatusLabel.font = statusFont
            questionStatusLabel.text = "assignment.correct".localiz()
        case .incorrect:
            questionStatusLabel.textColor = .red
            questionStatusLabel.font = statusFont
            questionStatusLabel.text = "assignment.incorrect".localiz()
        case .needsImprovement:
            questionStatusLabel.textColor = .orange
            questionStatusLabel.font = statusFont
            questionStatusLabel.text = "assignment.needsImprovement".localiz()
        case .notReviewed:
            questionStatusLabel.textColor = Asset.Colors.sendButtonColor.color
            questionStatusLabel.font = statusFont
            questionStatusLabel.text = "assignment.notReviewed".localiz()
        }
    }

    private func setLabelWithAttribute(_ text: String, _ attributes: [NSAttributedString.Key: Any], _ label: UILabel) {
        let attributedString = NSMutableAttributedString(string: text, attributes: attributes as [NSAttributedString.Key: Any])
        label.attributedText = attributedString
    }

    private func configureUI() {
        let alignment: NSTextAlignment = Language.currentLanguage == .arabic ? .left : .right
        numberOfPointsLabel.textAlignment =  alignment
        questionStatusLabel.textAlignment =  alignment
    }
}
