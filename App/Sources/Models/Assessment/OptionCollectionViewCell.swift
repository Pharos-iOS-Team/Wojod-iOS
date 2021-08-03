// Copyright © 2020 Pharos Solutions GmbH. All rights reserved.

// swiftlint:disable all

import UIKit
import SkeletonView

class OptionCollectionViewCell: UICollectionViewCell {
    @IBOutlet private weak var badgeButton: UIButton! {
        didSet {
            badgeButton.layer.backgroundColor = UIColor.orange.cgColor
        }
    }
    @IBOutlet private weak var titleLabel: UILabel! {
        didSet {
            titleLabel.isSkeletonable = true
            titleLabel.numberOfLines = 1
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setFrameShape(.circular)
        badgeButton.setFrameShape(.circular)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        clipsToBounds = true
        isSkeletonable = true
    }
    
    var textColor: UIColor = .black {
        didSet {
            titleLabel.textColor = textColor
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        clipsToBounds = true
        badgeButton.isHidden = true
    }
    
    func setTitle(withTitle title: String?) {
        titleLabel.text = title
    }
    
    func setNotificationBadge(withValue value: String?) {
        clipsToBounds = value == nil
        badgeButton.isHidden = value == nil
        badgeButton.setTitle(value, for: .normal)
    }
    
    func selectCell() {
        backgroundColor = Asset.Colors.sendButtonColor.color
        textColor = .white
    }
    
    func configureDeselectedCell() {
        backgroundColor = .white
        textColor = .black
    }
}
