// Copyright © 2020 Pharos Solutions. All rights reserved.

import Foundation
import UIKit

extension UIView {
    @IBInspectable var doneAccessory: Bool {
        get {
            return self.doneAccessory
        }
        set (hasDone) {
            if hasDone {
                addDoneButtonOnKeyboard()
            }
        }
    }

    fileprivate func addDoneButtonOnKeyboard() {
        let doneToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: L10n.Global.Actions.done, style: .done, target: self, action: #selector(self.doneButtonAction))
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        switch self {
        case let textView as UITextView:
            textView.inputAccessoryView = doneToolbar
        case let textField as UITextField:
            textField.inputAccessoryView = doneToolbar
        default:
            return
        }
    }

    @objc
    fileprivate func doneButtonAction() {
        resignFirstResponder()
    }
}

extension UIView {
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }

    @IBInspectable var borderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.borderColor = color.cgColor
            } else {
                layer.borderColor = nil
            }
        }
    }

    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
}

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

    func removeBlurFromView() {
        for subview in self.subviews {
            if subview is UIVisualEffectView {
                subview.removeFromSuperview()
            }
        }
    }

    func addShadow(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = .zero
        layer.shadowRadius = 1
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }

    func addShadow(
        with color: UIColor?,
        offset: CGSize = CGSize.zero,
        radius: CGFloat = 0.0,
        opacity: Float = 1.0
    ) {
        layer.shadowColor = color?.cgColor
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
    }
}

extension UIView {
    func addSubviews(_ subviews: UIView...) {
        subviews.forEach { addSubview($0) }
    }
}

extension UIView {
    enum FrameShape {
        case circular
        case square
    }

    func setFrameShape(_ frameShape: FrameShape) {
        switch frameShape {
        case .circular:
            self.layer.cornerRadius = self.frame.height / 2
        default:
            break
        }
    }
}

extension UIView {
    func makeSecure() {
        guard superview != nil else {
            for subview in subviews { //to avoid layer cyclic crash, when it is a topmost view, adding all its subviews in textfield's layer, TODO: Find a better logic.
                subview.makeSecure()
            }
            return
        }
        let guardTextField = UITextField()
        guardTextField.backgroundColor = .red
        guardTextField.translatesAutoresizingMaskIntoConstraints = false
        guardTextField.isSecureTextEntry = true
        addSubview(guardTextField)
        sendSubviewToBack(guardTextField)
        layer.superlayer?.addSublayer(guardTextField.layer)
        guardTextField.layer.sublayers?.first?.addSublayer(layer)
        guardTextField.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        guardTextField.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        guardTextField.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        guardTextField.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
    }
}
