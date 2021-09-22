// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit

class TeacherQuestionCommentTableViewCell: UITableViewCell {
    @IBOutlet private var noteLabel: UILabel! {
        didSet {
            noteLabel.text = "Note:"
        }
    }
    @IBOutlet private var noteContainerTextView: UITextView!

    override func awakeFromNib() {
        super.awakeFromNib()
        configureView()
    }

    func configure(note: String) {
        noteContainerTextView.text = note
    }

    private func configureView() {
        noteContainerTextView.textContainerInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        noteContainerTextView.textContainer.lineFragmentPadding = 0
        noteContainerTextView.layer.cornerRadius = 10
        noteContainerTextView.layer.borderWidth = 1
        noteContainerTextView.layer.borderColor = Asset.Colors.orange.color.cgColor.copy(alpha: 0.2)
        noteContainerTextView.isEditable = false
        noteContainerTextView.backgroundColor = Asset.Colors.orange.color.withAlphaComponent(0.2)
    }
}
