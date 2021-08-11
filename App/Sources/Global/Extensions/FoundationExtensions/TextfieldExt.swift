// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit

extension UITextField {
    internal func addLeftIcon(_ image: UIImage, width: CGFloat, height: CGFloat) {
        leftViewMode = .always
        let containerView = UIView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: width + 20,
                height: height
            )
        )
        let imageView = UIImageView(
            frame: CGRect(
                x: 10,
                y: 0,
                width: width,
                height: height
            )
        )
        imageView.image = image
        containerView.addSubview(imageView)
        leftView = containerView
    }

    internal func addRightIcon(_ image: UIImage, width: CGFloat, height: CGFloat) {
        rightViewMode = .always
        let containerView = UIView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: width + 20,
                height: height
            )
        )
        let imageView = UIImageView(
            frame: CGRect(
                x: 10,
                y: 0,
                width: width,
                height: height
            )
        )
        imageView.image = image
        containerView.addSubview(imageView)
        rightView = containerView
    }
}
