// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit

class MaterialTableViewCell: UITableViewCell {
    @IBOutlet private var nextArrowIndicator: UIImageView! {
        didSet {
            nextArrowIndicator.image = Images.localizedNextArrowIndicator
        }
    }
    @IBOutlet private var containerView: UIView! {
        didSet {
            containerView.layer.cornerRadius = UIConstants.cornerRadius
        }
    }
    @IBOutlet private var iconImageView: UIImageView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var dateLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    internal func configure(title: String?, date: String?, image: UIImage?) {
        titleLabel.text = title
        dateLabel.text = date
        iconImageView.image = image
    }
}
