// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit
import HandyUIKit

class NavigationBar: UIView, NibLoadable {
    override init(frame: CGRect) {
        super.init(frame: frame)
        try? loadFromNib()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        try? loadFromNib()
    }
}
