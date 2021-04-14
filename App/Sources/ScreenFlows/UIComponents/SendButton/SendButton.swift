// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit

class SendButton: UIButton {
    private enum Constants {
        static let cornerRadius: CGFloat = 6
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = Colors.sendButtonColor.color
        setTitleColor(.white, for: .normal)
        setImage(Images.localizedDisclosureIndicatorButton)
        layer.cornerRadius = Constants.cornerRadius
        configureEdgeInsets()
    }

    private func configureEdgeInsets() {
        guard currentTitle != nil else { return }
        switch Language.currentLanguage {
        case .arabic:
            titleEdgeInsets = UIEdgeInsets(right: -bounds.maxX / 2)
            imageEdgeInsets = UIEdgeInsets(left: -bounds.maxX)
        default:
            titleEdgeInsets = UIEdgeInsets(left: -(bounds.maxX + bounds.midX) / 2)
            imageEdgeInsets = UIEdgeInsets(right: -bounds.maxX)
        }
        let buttonWidth = frame.width
        let imageWidth = imageView!.frame.width
        let spacing: CGFloat = 8.0 / 2
        contentEdgeInsets = UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: spacing)
    }
}
