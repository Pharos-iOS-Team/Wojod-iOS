// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit

class UICollectionViewLocalizableFlowLayout: UICollectionViewFlowLayout {
    override var flipsHorizontallyInOppositeLayoutDirection: Bool {
        return Language.currentLanguage == .arabic
    }
}
