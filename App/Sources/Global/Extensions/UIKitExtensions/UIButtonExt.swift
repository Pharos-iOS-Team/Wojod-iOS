// Copyright © 2020 Pharos Solutions. All rights reserved.

import UIKit

extension UIButton {
    func setImage(_ imageAsset: ImageAsset, state: UIControl.State = .normal) {
        setImage(imageAsset.image, for: state)
    }

    func setImage(_ image: UIImage, state: UIControl.State = .normal) {
        setImage(image, for: state)
    }

    func setTitle(_ title: String?, state: UIControl.State = .normal) {
        setTitle(title, for: .normal)
    }
}
