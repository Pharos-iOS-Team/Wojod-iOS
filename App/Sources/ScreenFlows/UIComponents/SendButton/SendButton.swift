// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit

class SendButton: UIButton {
    private enum Constants {
        static let cornerRadius: CGFloat = 6
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = Colors.sendButtonColor.color
        setImage(Images.localizedDisclosureIndicatorButton)
        layer.cornerRadius = Constants.cornerRadius
        checkForLanguageAlignment()
        checkForButtonTitle()
    }

    private func checkForLanguageAlignment() {
        switch Language.currentLanguage {
        case .arabic:
            titleEdgeInsets = UIEdgeInsets(right: (bounds.maxX + bounds.midX) / 2 * -1)
            imageEdgeInsets = UIEdgeInsets(left: bounds.maxX * -1)
        default:
            titleEdgeInsets = UIEdgeInsets(left: (bounds.maxX + bounds.midX) / 2 * -1)
            imageEdgeInsets = UIEdgeInsets(right: bounds.maxX * -1)
        }
    }

    private func checkForButtonTitle() {
        guard currentTitle != nil else {
            titleEdgeInsets = UIEdgeInsets.zero
            imageEdgeInsets = UIEdgeInsets.zero
            return
        }
    }
}
