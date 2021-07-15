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

    func setSubject(_ subjectName: String) {
        subjectLabel.text = subjectName
    }

    func select() {
        subjectLabel.textColor = Colors.sendButtonColor.color
        underLinedView.isHidden = false
    }

    func unselect() {
        subjectLabel.textColor = Colors.labelGreyColor.color
        underLinedView.isHidden = true
    }
}
