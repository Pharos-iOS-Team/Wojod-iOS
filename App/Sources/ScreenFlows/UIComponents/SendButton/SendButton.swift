// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit

class SendButton: UIButton {
    private enum Constants {
        static let cornerRadius: CGFloat = 6
        static let titleOffset: CGFloat = 25
    }

    override var isEnabled: Bool {
        didSet {
            backgroundColor = isEnabled ? Colors.sendButtonColor.color : .systemGray3
        }
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
            imageEdgeInsets = UIEdgeInsets(left: 10)
        case .english:
            imageEdgeInsets = UIEdgeInsets(right: 10)
            titleEdgeInsets = UIEdgeInsets(right: imageView?.frame.width ?? .zero)
        }
        let spacing: CGFloat = 8.0 / 2
        contentEdgeInsets = UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: spacing)
    }

    override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        let titleRect = super.titleRect(forContentRect: contentRect)
        let pointX = (Language.semanticContent == .forceLeftToRight) ? Constants.titleOffset : contentRect.maxX - titleRect.width - Constants.titleOffset

        return CGRect(origin: CGPoint(x: pointX, y: titleRect.minY), size: titleRect.size)
    }

    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        let imageRect = super.imageRect(forContentRect: contentRect)
        let imageSize = currentImage?.size ?? .zero
        if currentTitle == nil {
            let centerX = (contentRect.width - imageSize.width) / 2
            let centerY = (contentRect.height - imageSize.height) / 2
            return CGRect(origin: CGPoint(x: centerX, y: centerY), size: imageSize)
        }
        let availableWidth = contentRect.width - imageEdgeInsets.right - imageSize.width - imageRect.width

        let pointX = (Language.semanticContent == .forceLeftToRight) ? availableWidth : Constants.titleOffset
        return CGRect(origin: CGPoint(x: pointX, y: imageRect.minY), size: imageSize)
    }
}
