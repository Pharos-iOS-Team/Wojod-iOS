// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit
extension UIWindow {
    func switchRootViewController(
        _ viewController: UIViewController,
        animated: Bool = true,
        duration: TimeInterval = 0.5,
        options: UIView.AnimationOptions = UIView.AnimationOptions.transitionCrossDissolve,
        completion: (() -> Void)? = nil
    ) {
        rootViewController?.dismiss(animated: false)
        guard animated else {
            rootViewController = viewController
            return
        }
        UIView.transition(
            with: self,
            duration: duration,
            options: options,
            animations: { [weak self] in
                let oldState = UIView.areAnimationsEnabled
                UIView.setAnimationsEnabled(false)
                self?.rootViewController = viewController
                UIView.setAnimationsEnabled(oldState)
            },
            completion: { _ in
                completion?()
            }
        )
    }
}
