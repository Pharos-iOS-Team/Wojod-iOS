// Copyright © 2022 Pharos Solutions. All rights reserved.

import HandyUIKit
import Foundation

class UITagLabel: UIPaddingLabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    private func setupView() {
        cornerRadius = 3.0
        leftInset = 10.0
        rightInset = 10.0
        topInset = 5.0
        bottomInset = 5.0
        backgroundColor = Colors.orange.color.withAlphaComponent(0.12)
        textColor = Colors.orange.color
        font = FontFamily.Inter.medium.font(size: 12)
        textAlignment = .center
    }
}
