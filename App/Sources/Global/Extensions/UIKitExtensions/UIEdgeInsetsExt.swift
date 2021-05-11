// Copyright © 2020 Pharos Solutions. All rights reserved.

import UIKit

extension UIEdgeInsets {
    static var standard: UIEdgeInsets {
        return horizontal(value: 8.0)
    }

    static func horizontal(value: CGFloat) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: value, bottom: 0, right: value)
    }

    init(top: CGFloat) {
        self.init(top: top, left: 0, bottom: 0, right: 0)
    }

    init(left: CGFloat) {
        self.init(top: 0, left: left, bottom: 0, right: 0)
    }

    init(bottom: CGFloat) {
        self.init(top: 0, left: 0, bottom: bottom, right: 0)
    }

    init(right: CGFloat) {
        self.init(top: 0, left: 0, bottom: 0, right: right)
    }
}
