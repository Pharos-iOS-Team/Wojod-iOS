// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit

class SendButton: UIButton {
    private enum Constants {
        static let cornerRadius: CGFloat = 6
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = Colors.sendButtonColor.color
        setImage(Images.localizedDisclosureIndicatorButton)
        layer.cornerRadius = Constants.cornerRadius
        configureEdgeInsets()
    }

    private func configureEdgeInsets() {
        guard currentTitle != nil else { return }
        switch Language.currentLanguage {
        case .arabic:
            titleEdgeInsets = UIEdgeInsets(right: (bounds.maxX + bounds.midX) / 2 * -1)
            imageEdgeInsets = UIEdgeInsets(left: bounds.maxX * -1)
        default:
            titleEdgeInsets = UIEdgeInsets(left: (bounds.maxX + bounds.midX) / 2 * -1)
            imageEdgeInsets = UIEdgeInsets(right: bounds.maxX * -1)
        }
    }
}
