// Copyright © 2026 Pharos Solutions. All rights reserved.

import UIKit

final class TextFieldLoadingIndicator {
    private var savedRightViews: [UITextField: UIView] = [:]

    func showLoading(on textField: UITextField) {
        savedRightViews[textField] = textField.rightView
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.color = Colors.sendButtonColor.color
        spinner.startAnimating()
        spinner.hidesWhenStopped = true
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 20))
        spinner.frame = CGRect(x: 5, y: 0, width: 20, height: 20)
        containerView.addSubview(spinner)
        textField.rightView = containerView
        textField.rightViewMode = .always
    }

    func hideLoading(on textField: UITextField) {
        textField.rightView = savedRightViews[textField]
        savedRightViews.removeValue(forKey: textField)
        textField.rightViewMode = .always
    }
}
