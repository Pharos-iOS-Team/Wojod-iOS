// Copyright © 2020 Pharos Solutions. All rights reserved.

import Foundation
import UIKit

extension String {
    func attributedText(foregroundColor: UIColor, font: UIFont, kern: Float) -> NSMutableAttributedString {
        NSMutableAttributedString(string: self, attributes: [.font: font, .foregroundColor: foregroundColor, .kern: kern])
    }

    func rangeOf(substring: String) -> NSRange? {
        let substringRange = range(of: substring.self)
        guard let range = substringRange else { return nil }

        let swiftRange: Range<String.Index> = range
        let nsRange = NSRange(swiftRange, in: substring)
        return nsRange
    }
}


extension String {
    var isValidURL: Bool {
        if let url = NSURL(string: self) {
            return UIApplication.shared.canOpenURL(url as URL)
        }
        return false
    }
}
