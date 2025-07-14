// Copyright © 2020 Pharos Solutions. All rights reserved.

import Foundation
import UIKit

class LoadingButton: UIButton {
    func startLoading() {
        self.isEnabled = false
        startSpinning()
    }

    func stopLoading() {
        if let activityIndicator = self.subviews.first(where: { $0 is UIActivityIndicatorView }) as? UIActivityIndicatorView {
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()
            self.setTitleColor(activityIndicator.color, for: .normal)
        }
        self.isEnabled = true
    }

    private func createActivityIndicator(color: UIColor?) -> UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = color ?? .lightGray
        return activityIndicator
    }

    private func startSpinning() {
        let tintColor = self.titleColor(for: .normal)
        self.setTitleColor(.clear, for: .disabled)
        let activityIndicator = createActivityIndicator(color: tintColor)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(activityIndicator)
        centerActivityIndicatorInButton(activityIndicator)
        activityIndicator.startAnimating()
    }

    private func centerActivityIndicatorInButton(_ activityIndicator: UIActivityIndicatorView) {
        let xCenterConstraint = NSLayoutConstraint(
            item: self,
            attribute: .centerX,
            relatedBy: .equal,
            toItem: activityIndicator,
            attribute: .centerX,
            multiplier: 1,
            constant: 0
        )
        self.addConstraint(xCenterConstraint)
        let yCenterConstraint = NSLayoutConstraint(
            item: self,
            attribute: .centerY,
            relatedBy: .equal,
            toItem: activityIndicator,
            attribute: .centerY,
            multiplier: 1,
            constant: 0
        )
        self.addConstraint(yCenterConstraint)
    }
}
