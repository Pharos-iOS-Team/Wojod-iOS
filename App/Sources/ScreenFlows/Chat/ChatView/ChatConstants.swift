// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit

enum ChatConstants {
    static let senderBackgroundColor: UIColor = Asset.Colors.sendButtonColor.color
    static let senderTextColor: UIColor = .white
    static let reciverBackgroundColor: UIColor = Asset.Colors.lightGreyColor.color
    static let reciverTextColor: UIColor = .black
    static let sendButtonColor: UIColor = Asset.Colors.sendButtonColor.color
    static let sendButtonColorDimmed: UIColor = Asset.Colors.sendButtonColor.color.withAlphaComponent(0.5)
    static let messageHorizontalPadding: CGFloat = 10
    static let messageVerticalPadding: CGFloat = 4
    static let messageDateHeight: CGFloat = 15
    static let dateFont: UIFont = FontFamily.Inter.regular.font(size: 11)
    static let inputBarItemWidth: CGFloat = 36
    static let numberOfLeftInputBarItems: CGFloat = 2
}
