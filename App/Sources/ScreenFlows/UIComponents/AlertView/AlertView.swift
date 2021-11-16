// Copyright © 2021 Pharos Solutions. All rights reserved.

import HandyUIKit
import UIKit

class AlertView: UIView, NibLoadable {
    private enum Constants {
        static let cornerRadius: CGFloat = 8
    }

    @IBOutlet private var errorImageView: UIImageView! {
        didSet {
            errorImageView.image = Images.errorSymbol.image
        }
    }

    @IBOutlet private var errorLabel: UILabel! {
        didSet {
            errorLabel.textColor = Colors.errorAlertLabelColor.color
        }
    }

    var message: String? {
        didSet {
            errorLabel.text = message
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setBackGroundColorAndCornerRadius()
        try? loadFromNib(bundle: Bundle.main)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setBackGroundColorAndCornerRadius()
        try? loadFromNib(bundle: Bundle.main)
    }

    private func setBackGroundColorAndCornerRadius() {
        backgroundColor = Colors.errorAlertBackgroundColor.color
        layer.cornerRadius = Constants.cornerRadius
        layer.masksToBounds = true
    }

    func hideAlertView() {
        isHidden = true
    }

    func showAlertView() {
        isHidden = false
    }
}
