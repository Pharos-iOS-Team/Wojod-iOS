// Copyright © 2020 Pharos Solutions. All rights reserved.

import HandyUIKit
import UIKit

class FormTextField: UITextField {
    enum TextFieldConstants {
        static let defaultPadding: CGFloat = 18.0
    }

    @IBInspectable var labelText: String? {
        didSet {
            configureView()
        }
    }

    var showLabel: Bool = true {
        didSet {
            if showLabel {
                labelPadding = UIEdgeInsets.horizontal(value: 40)
            } else {
                labelPadding = UIEdgeInsets.horizontal(value: TextFieldConstants.defaultPadding)
            }
        }
    }

    private var labelPadding = UIEdgeInsets.horizontal(value: TextFieldConstants.defaultPadding)

    override func awakeFromNib() {
        super.awakeFromNib()
        configureView()
        textAlignment = Language.currentLanguage == .english ? .right : .left
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: labelPadding)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: labelPadding)
    }

    private func configureView() {
        guard let labelText = labelText else { return }
        let label = UILabel(frame: CGRect(width: 45, height: 25)).with {
            $0.font = UIFont(name: "Inter", size: 14)
            $0.text = labelText
            $0.textAlignment = Language.textAlignment
        }
        leftViewMode = .always
        leftView = UIView(frame: label.frame)
        leftView?.addSubview(label)
        label.bindEdgesToSuperview(insets: UIEdgeInsets.horizontal(value: 10))
    }
}
