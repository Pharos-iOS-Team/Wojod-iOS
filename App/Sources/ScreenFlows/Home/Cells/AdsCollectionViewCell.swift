// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit

class AdsCollectionViewCell: UICollectionViewCell {
    @IBOutlet private var adsContentView: UIView! {
        didSet {
            adsContentView.layer.cornerRadius = UIConstants.slightCornerRadius
        }
    }
    @IBOutlet private var viewMoreButton: UIButton! {
        didSet {
            viewMoreButton.layer.cornerRadius = UIConstants.slightCornerRadius
        }
    }
}
