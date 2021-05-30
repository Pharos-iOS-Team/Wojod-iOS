// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit

extension UIViewController {
    internal func configureSemanticAttribute() {
        UIView.appearance().semanticContentAttribute = Language.currentLanguage == .arabic ? .forceRightToLeft : .forceLeftToRight
    }
}
