// Copyright © 2020 Pharos Solutions. All rights reserved.

import Foundation
import UIKit

extension UITextField {
    enum PaddingSide {
        case left(CGFloat)
        case right(CGFloat)
        case both(CGFloat)
    }

    func addPadding(_ padding: PaddingSide) {
        leftViewMode = .always
        layer.masksToBounds = true
        switch padding {
        case .left(let spacing):
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: spacing, height: frame.height))
            leftView = paddingView
            rightViewMode = .always

        case .right(let spacing):
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: spacing, height: frame.height))
            rightView = paddingView
            rightViewMode = .always

        case .both(let spacing):
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: spacing, height: frame.height))
            leftView = paddingView
            leftViewMode = .always
            rightView = paddingView
            rightViewMode = .always
        }
    }
}

extension UITextField {
    var isEmpty: Bool {
        guard let text = text else { return true }
        return text.isEmpty
    }
}
