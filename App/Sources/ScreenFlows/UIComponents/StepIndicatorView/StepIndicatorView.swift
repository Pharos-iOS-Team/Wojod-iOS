// Copyright © 2026 Pharos Solutions. All rights reserved.

import UIKit
// swiftlint:disable all

@IBDesignable
final class StepIndicatorView: UIView {
    @IBInspectable var currentStep: Int = 1 {
        didSet { setNeedsDisplay() }
    }
    @IBInspectable var totalSteps: Int = 3 {
        didSet { setNeedsDisplay() }
    }
    @IBInspectable var dotHeight: CGFloat = 8 {
        didSet { setNeedsDisplay() }
    }
    @IBInspectable var dotWidth: CGFloat = 8 {
        didSet { setNeedsDisplay() }
    }
    @IBInspectable var activeWidth: CGFloat = 22 {
        didSet { setNeedsDisplay() }
    }
    @IBInspectable var spacing: CGFloat = 6 {
        didSet { setNeedsDisplay() }
    }

    private let activeColor: UIColor = Colors.sendButtonColor.color
    private let inactiveColor: UIColor = .lightGray.withAlphaComponent(0.4)

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
    }

    override var intrinsicContentSize: CGSize {
        var totalW: CGFloat = 0
        for i in 1...max(totalSteps, 1) {
            totalW += (i == currentStep ? activeWidth : dotWidth)
            if i < totalSteps { totalW += spacing }
        }
        return CGSize(width: totalW, height: dotHeight)
    }

    override func draw(_ rect: CGRect) {
        guard totalSteps > 0 else { return }
        var x: CGFloat = 0
        for i in 1...totalSteps {
            let w = i == currentStep ? activeWidth : dotWidth
            (i <= currentStep ? activeColor : inactiveColor).setFill()
            UIBezierPath(roundedRect: CGRect(x: x, y: 0, width: w, height: dotHeight),
                         cornerRadius: dotHeight / 2).fill()
            x += w + spacing
        }
    }

    static func makeImage(currentStep: Int, totalSteps: Int = 3) -> UIImage {
        let dotH: CGFloat = 8
        let dotW: CGFloat = 8
        let activeW: CGFloat = 22
        let spacing: CGFloat = 6
        var totalW: CGFloat = 0
        for index in 1...totalSteps { totalW += (index == currentStep ? activeW : dotW) + (index < totalSteps ? spacing : 0) }
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: totalW, height: dotH))
        let active = Colors.sendButtonColor.color
        let inactive = UIColor.lightGray.withAlphaComponent(0.4)
        return renderer.image { _ in
            var steps: CGFloat = 0
            for index in 1...totalSteps {
                let width = index == currentStep ? activeW : dotW
                (index <= currentStep ? active : inactive).setFill()
                UIBezierPath(roundedRect: CGRect(x: steps, y: 0, width: width, height: dotH), cornerRadius: dotH / 2).fill()
                steps += width + spacing
            }
        }
    }
}
