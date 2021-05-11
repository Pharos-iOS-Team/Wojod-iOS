// Copyright © 2021 Pharos Solutions. All rights reserved.

import HandyUIKit
import UIKit

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
