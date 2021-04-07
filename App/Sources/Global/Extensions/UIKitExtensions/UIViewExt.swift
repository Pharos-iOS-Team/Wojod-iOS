// Copyright © 2020 Pharos Solutions. All rights reserved.

import Foundation
import UIKit

extension UIView {
    func setBorder(color: UIColor, width: CGFloat, cornerRadius: CGFloat) {
        layer.borderColor = color.cgColor
        layer.borderWidth = width
        layer.cornerRadius = cornerRadius
    }

    func setTopCornerRadius(radius: CGFloat) {
        layer.masksToBounds = true
        layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        layer.cornerRadius = radius
    }

    func setBottomCornerRadius(radius: CGFloat) {
        layer.masksToBounds = true
        layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        layer.cornerRadius = radius
    }

    func setLeftCornerRadius(radius: CGFloat) {
        layer.masksToBounds = true
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        layer.cornerRadius = radius
    }

    func setRightCornerRadius(radius: CGFloat) {
        layer.masksToBounds = true
        layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        layer.cornerRadius = radius
    }

    func setSenderMessageCornerRadius(radius: CGFloat) {
        layer.masksToBounds = true
        layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner, .layerMaxXMaxYCorner]
        layer.cornerRadius = radius
    }

    func setReciverMessageCornerRadius(radius: CGFloat) {
        layer.masksToBounds = true
        layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        layer.cornerRadius = radius
    }

    func makeRounded() {
        layer.masksToBounds = true
        layer.cornerRadius = bounds.height / 2
    }

    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }

    @discardableResult
    func addLineDashedStroke(pattern: [NSNumber]?, radius: CGFloat, colorAsset: ColorAsset) -> CALayer {
        let borderLayer = CAShapeLayer().with {
            $0.strokeColor = colorAsset.color.cgColor
            $0.lineDashPattern = pattern
            $0.frame = bounds
            $0.fillColor = nil
            $0.path = UIBezierPath(
                roundedRect: bounds,
                byRoundingCorners: .allCorners,
                cornerRadii: CGSize(width: radius, height: radius)
            ).cgPath
        }

        layer.addSublayer(borderLayer)
        return borderLayer
    }
}

extension UIView {
    func addSubviews(_ subviews: UIView...) {
        subviews.forEach { addSubview($0) }
    }
}
