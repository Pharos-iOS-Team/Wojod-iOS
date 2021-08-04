// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit

class SubjectCollectionViewCell: UICollectionViewCell {
    @IBOutlet private var subjectLabel: UILabel! {
        didSet {
            subjectLabel.sizeToFit()
        }
    }
    @IBOutlet private var underLinedView: UIView! {
        didSet {
            underLinedView.isHidden = true
        }
    }

    override var isSelected: Bool {
        willSet {
            super.isSelected = newValue
            if newValue {
                selectSubject()
            } else {
                unselectSubject()
            }
        }
    }

    func setSubject(_ subjectName: String) {
        subjectLabel.text = subjectName
    }

    func selectSubject() {
        subjectLabel.textColor = Colors.sendButtonColor.color
        underLinedView.isHidden = false
    }

    func unselectSubject() {
        subjectLabel.textColor = Colors.labelGreyColor.color
        underLinedView.isHidden = true
    }
}
