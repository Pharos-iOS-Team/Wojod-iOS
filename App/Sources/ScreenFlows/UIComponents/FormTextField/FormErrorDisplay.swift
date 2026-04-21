// Copyright © 2026 Pharos Solutions. All rights reserved.

import UIKit

final class FormErrorDisplay {
    private var errorLabels: [UITextField: UILabel] = [:]

    func attachErrorLabels(to textFields: [UITextField]) {
        for textField in textFields {
            let label = UILabel()
            label.font = .systemFont(ofSize: 12)
            label.textColor = .systemRed
            label.numberOfLines = 0
            label.isHidden = true
            label.translatesAutoresizingMaskIntoConstraints = false
            textField.superview?.addSubview(label)
            NSLayoutConstraint.activate([
                label.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 2),
                label.leadingAnchor.constraint(equalTo: textField.leadingAnchor),
                label.trailingAnchor.constraint(equalTo: textField.trailingAnchor)
            ])
            errorLabels[textField] = label
        }
    }

    func showError(for textField: UITextField, message: String) {
        errorLabels[textField]?.text = message
        errorLabels[textField]?.isHidden = false
    }

    func clearError(for textField: UITextField) {
        errorLabels[textField]?.isHidden = true
        textField.setBorder(color: Asset.Colors.backgroundLightGreyColor.color, width: 1, cornerRadius: 5)
    }

    func clearAll() {
        errorLabels.values.forEach { $0.isHidden = true }
    }
}
