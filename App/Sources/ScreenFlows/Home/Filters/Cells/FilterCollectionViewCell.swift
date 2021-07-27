// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit

class FilterCollectionViewCell: UICollectionViewCell {
    // MARK: - IBOutlets

    @IBOutlet private var label: UILabel!
    @IBOutlet private var filterContentView: UIView! {
        didSet {
            filterContentView.layer.cornerRadius = UIConstants.cornerRadius
        }
    }

    override var isSelected: Bool{
        willSet{
            super.isSelected = newValue
            if newValue
            {
                selectFilter()
            }
            else
            {
                unselectFilter()
            }
        }
    }

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    // MARK: - Public Functions

    func configure(with title: String) {
        label.text = title
    }

    func selectFilter() {
        filterContentView.layer.backgroundColor = Colors.lightAccentColor.color.cgColor
        label.textColor = Colors.sendButtonColor.color
    }

    func unselectFilter() {
        filterContentView.layer.backgroundColor = Colors.lightGreyColor.color.cgColor
        label.textColor = .black
    }
}
