// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit

class SubjectCollectionViewCell: UICollectionViewCell {
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var underlinedView: UIView! {
        didSet {
            underlinedView.isHidden = true
        }
    }

    func setSubject(_ subjectName: String) {
        titleLabel.text = subjectName
    }

    func select() {
        titleLabel.textColor = Colors.sendButtonColor.color
        underlinedView.isHidden = false
    }

    func unselect() {
        titleLabel.textColor = Colors.labelGreyColor.color
        underlinedView.isHidden = true
    }
}
