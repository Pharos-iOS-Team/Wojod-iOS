//  Copyright © 2020 Pharos Solutions GmbH. All rights reserved.

// swiftlint:disable all

import UIKit

class AssessmentDetailOverviewInstructionsTableViewCell: UITableViewCell {
    @IBOutlet private var containerView: UIView!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var instructionsLabel: UILabel!

    private let fontSize: CGFloat = 14

    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }

    func configure(instructions: String?, module: AssessmentsOverViewViewModel.Module) {
        if module == .assignments {
            descriptionLabel.text = L10n.Assignment.descriptionTitle + ":"
        }
        guard let instructions = instructions else { return }
        let textAlignment: NSTextAlignment = instructions.dominantTextAlignment
        configureInstructions(instructions, alignment: textAlignment)
    }

    private func configureInstructions(_ text: String?, alignment: NSTextAlignment) {
        guard let attributedString = text?.convertHtml(size: fontSize)
            else { return }
        let instructionsAttributedString = NSMutableAttributedString(attributedString: attributedString)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = alignment
        paragraphStyle.lineSpacing = 2
        instructionsAttributedString.addAttribute(
            NSAttributedString.Key.paragraphStyle,
            value: paragraphStyle,
            range: NSMakeRange(0, instructionsAttributedString.length)
        )
        instructionsLabel.attributedText = instructionsAttributedString
    }

    private func configureUI() {
        selectionStyle = .none
        backgroundColor = .clear
        containerView.backgroundColor = Asset.Colors.sendButtonColor.color.withAlphaComponent(0.11)
        containerView.layer.cornerRadius = 17
    }
}
