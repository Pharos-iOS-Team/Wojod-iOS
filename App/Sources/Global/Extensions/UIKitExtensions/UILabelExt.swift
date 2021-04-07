// Copyright © 2020 Pharos Solutions. All rights reserved.

import UIKit

extension UILabel {
    convenience init(badgeText: String, color: UIColor = .red, fontSize: CGFloat = UIFont.smallSystemFontSize) {
        self.init()
        text = badgeText.count > 1 ? " \(badgeText) " : badgeText
        textAlignment = .center
        textColor = .white
        backgroundColor = color
        font = UIFont.systemFont(ofSize: fontSize)
        layer.cornerRadius = fontSize * CGFloat(0.6)
        clipsToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
        addConstraint(
            NSLayoutConstraint(
                item: self,
                attribute: .width,
                relatedBy: .greaterThanOrEqual,
                toItem: self,
                attribute: .height,
                multiplier: 1,
                constant: 0
            )
        )
    }

    func adjustFontSizeToFit() {
        guard var font = self.font, let text = self.text else { return }
        let size = self.frame.size
        var maxSize = font.pointSize
        while maxSize >= self.minimumScaleFactor * self.font.pointSize {
            font = font.withSize(maxSize)
            let constraintSize = CGSize(width: size.width, height: .greatestFiniteMagnitude)
            let textRect = (text as NSString).boundingRect(
                with: constraintSize,
                options: .usesLineFragmentOrigin,
                attributes: [.font: font],
                context: nil
            )
            let labelSize = textRect.size
            if labelSize.height <= size.height {
                self.font = font
                setNeedsLayout()
                break
            }
            maxSize -= 1
        }
        self.font = font
        setNeedsLayout()
    }
}
