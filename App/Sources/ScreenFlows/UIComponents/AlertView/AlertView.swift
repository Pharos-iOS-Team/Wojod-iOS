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

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Colors.errorAlertBackgroundColor.color
        layer.cornerRadius = Constants.cornerRadius
        try? loadFromNib()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = Colors.errorAlertBackgroundColor.color
        layer.cornerRadius = Constants.cornerRadius
        try? loadFromNib()
    }

    func setErrorMessage(message: String?) {
        errorLabel.text = message
    }
}
